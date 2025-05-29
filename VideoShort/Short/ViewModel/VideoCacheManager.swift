import Foundation
import AVFoundation

class VideoCacheManager: NSObject, ObservableObject {
    static let shared = VideoCacheManager()
    @Published var isComplite : Bool = false {
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ){ [weak self] in
                self?.isComplite = false
            }
        }
    }
    
    // MARK: - Properties
    private let downloadQueue = OperationQueue()
    private var cachedVideos: [String: URL] = [:] // URL string -> Local file URL
    private var cache: [String: AVPlayerItem] = [:] // URL string -> AVPlayerItem from local file
    private let maxCacheSize: Int
    private var cacheOrder: [String] = [] // To maintain LRU order
    private let lock = NSLock()
    
    // Progress tracking
    private var downloadTasks: [String: URLSessionDownloadTask] = [:]
    private var downloadStartTimes: [String: Date] = [:]
    
    // MARK: - Preload Queue Management
    private var preloadQueue: [String] = [] // URLs to preload in order
    private var currentlyPreloading: String? = nil // Currently downloading URL
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = CacheConfiguration.downloadTimeout
        config.timeoutIntervalForResource = 300.0
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }()
    
    // File manager
    private let fileManager = FileManager.default
    private lazy var cacheDirectory: URL = {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheURL = urls[0].appendingPathComponent("VideoCache")
        try? fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        return cacheURL
    }()
    
    // MARK: - Initialization
    override init() {
        self.maxCacheSize = CacheConfiguration.maxCacheSize
        super.init()
        self.downloadQueue.maxConcurrentOperationCount = CacheConfiguration.maxConcurrentDownloads
        self.downloadQueue.qualityOfService = .background
        loadExistingCache()
    }
    
    init(maxCacheSize: Int = CacheConfiguration.maxCacheSize) {
        self.maxCacheSize = maxCacheSize
        super.init()
        self.downloadQueue.maxConcurrentOperationCount = CacheConfiguration.maxConcurrentDownloads
        self.downloadQueue.qualityOfService = .background
        loadExistingCache()
    }
    
    // MARK: - Public Methods
    
    /// Get cached video item or create new one from URL
    func getVideoItem(for url: String) -> AVPlayerItem {
        lock.lock()
        defer { lock.unlock() }
        
        // Check if we have a cached local file
        if let localURL = cachedVideos[url] {
            // Verify file still exists
            if fileManager.fileExists(atPath: localURL.path) {
                // Create or get cached AVPlayerItem from local file
                if let cachedItem = cache[url] {
                    updateCacheOrder(for: url)
                    logCacheEvent("📱 Playing from cached file", url: url)
                    return cachedItem
                } else {
                    let playerItem = AVPlayerItem(url: localURL)
                    cache[url] = playerItem
                    updateCacheOrder(for: url)
                    logCacheEvent("📱 Created player from cached file", url: url)
                    return playerItem
                }
            } else {
                // File was deleted, remove from cache
                cachedVideos.removeValue(forKey: url)
                cache.removeValue(forKey: url)
                logCacheEvent("⚠️ Cached file was deleted, falling back to URL", url: url)
            }
        }
        
        // 🎯 NEW: Check if this video is currently downloading or in queue
        handleCurrentVideoRequest(for: url)
        
        logCacheEvent("🌐 Playing from URL (prioritized over download)", url: url)
        return AVPlayerItem(url: URL(string: url)!)
    }
    
    /// Handle when user navigates to a video that's downloading or queued
    private func handleCurrentVideoRequest(for url: String) {
        var wasInQueue = false
        var wasDownloading = false
        
        // Remove from preload queue if present
        if let index = preloadQueue.firstIndex(of: url) {
            preloadQueue.remove(at: index)
            wasInQueue = true
            logCacheEvent("🎯 Removed from preload queue (user navigated here)", url: url)
        }
        
        // Cancel current download if it's this video
        if currentlyPreloading == url {
            if let task = downloadTasks[url] {
                task.cancel()
                logCacheEvent("⏹️ Cancelled download (user navigated here)", url: url)
                wasDownloading = true
            }
            
            // Clean up tracking
            downloadTasks.removeValue(forKey: url)
            downloadStartTimes.removeValue(forKey: url)
            currentlyPreloading = nil
        }
        
        // Log the action taken
        if wasInQueue || wasDownloading {
            let action = wasDownloading ? "downloading" : "queued"
            logCacheEvent("🔄 Prioritized user request over \(action) video", url: url)
            
            // Start next download in queue after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.processNextInQueue()
            }
        }
    }
    
    /// Cache videos starting from current position with preload distance
    func cacheVideosFromCurrentPosition(currentIndex: Int, videoUrls: [String]) {
        lock.lock()
        defer { lock.unlock() }
        
        let currentVideoUrl = videoUrls[safe: currentIndex]
        
        // 🎯 NEW: Handle if current video is downloading or queued
        if let currentUrl = currentVideoUrl {
            handleCurrentVideoRequest(for: currentUrl)
        }
        
        // Clear existing preload queue
        preloadQueue.removeAll()
        
        // Calculate preload range
        let startIndex = currentIndex + 1 // Start from next video
        let endIndex = min(startIndex + CacheConfiguration.preloadDistance - 1, videoUrls.count - 1)
        
        guard startIndex < videoUrls.count else {
            logCacheEvent("📱 No videos to preload (reached end)", url: nil)
            return
        }
        
        // Add videos to preload queue (skip already cached ones)
        for index in startIndex...endIndex {
            let url = videoUrls[index]
            
            // Skip if already cached
            if cachedVideos[url] != nil {
                logCacheEvent("⏭️ Skipping already cached video (index \(index))", url: url)
                continue
            }
            
            // Skip if it's the current video (already handled above)
            if url == currentVideoUrl {
                continue
            }
            
            preloadQueue.append(url)
            logCacheEvent("📋 Added to preload queue (index \(index))", url: url)
        }
        
        logCacheEvent("📋 Preload queue updated: \(preloadQueue.count) videos queued", url: nil)
        
        // Start next download if not currently downloading
        processNextInQueue()
    }
    
    /// Legacy method for single video caching (still supported)
    func cacheNextVideo(url: String) {
        lock.lock()
        defer { lock.unlock() }
        
        // Don't cache if already cached
        if cachedVideos[url] != nil {
            logCacheEvent("✅ Video already cached to file", url: url)
            return
        }
        
        // Add to front of queue for priority
        if let index = preloadQueue.firstIndex(of: url) {
            preloadQueue.remove(at: index)
        }
        preloadQueue.insert(url, at: 0)
        
        logCacheEvent("🔼 Added to priority queue", url: url)
        processNextInQueue()
    }
    
    // MARK: - Private Queue Management
    
    private func processNextInQueue() {
        // Don't start new download if already downloading
        guard currentlyPreloading == nil else {
            logCacheEvent("⏳ Download in progress, waiting...", url: currentlyPreloading)
            return
        }
        
        // Get next URL from queue
        guard let nextUrl = preloadQueue.first else {
            logCacheEvent("📭 Preload queue is empty", url: nil)
            return
        }
        
        // Remove from queue and start download
        preloadQueue.removeFirst()
        currentlyPreloading = nextUrl
        
        logCacheEvent("🎯 Starting next download from queue (\(preloadQueue.count) remaining)", url: nextUrl)
        startDownloadInternal(for: nextUrl)
    }
    
    private func startDownloadInternal(for url: String) {
        guard let videoURL = URL(string: url) else {
            logCacheEvent("❌ Invalid URL for caching", url: url)
            onDownloadCompleted(url: url, success: false)
            return
        }
        
        logCacheEvent("🔍 Testing URL accessibility", url: url)
        
        // Test URL first
        var request = URLRequest(url: videoURL)
        request.httpMethod = "HEAD"
        
        let testTask = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.logCacheEvent("❌ URL test failed: \(error.localizedDescription)", url: url)
                self.onDownloadCompleted(url: url, success: false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                self.logCacheEvent("📡 URL test response: \(httpResponse.statusCode)", url: url)
                
                if httpResponse.statusCode == 200 {
                    // URL is accessible, start download
                    DispatchQueue.main.async {
                        self.startDownload(for: url, videoURL: videoURL)
                    }
                } else {
                    self.logCacheEvent("❌ URL returned status: \(httpResponse.statusCode)", url: url)
                    self.onDownloadCompleted(url: url, success: false)
                }
            }
        }
        
        testTask.resume()
    }
    
    private func startDownload(for url: String, videoURL: URL) {
        // Record download start time
        downloadStartTimes[url] = Date()
        
        // Create download task
        let downloadTask = urlSession.downloadTask(with: videoURL)
        downloadTasks[url] = downloadTask
        
        logCacheEvent("🔄 Started downloading", url: url)
        downloadTask.resume()
        
        // Add timeout check
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.checkDownloadProgress(for: url)
        }
    }
    
    private func checkDownloadProgress(for url: String) {
        if let task = downloadTasks[url] {
            logCacheEvent("📊 Download status check - State: \(task.state.rawValue), Progress: \(task.progress.fractionCompleted)", url: url)
            
            if task.state == .suspended {
                logCacheEvent("⚠️ Download was suspended, resuming...", url: url)
                task.resume()
            }
        }
    }
    
    private func onDownloadCompleted(url: String, success: Bool) {
        lock.lock()
        // Clear currently downloading
        if currentlyPreloading == url {
            currentlyPreloading = nil
        }
        lock.unlock()
        
        if success {
            logCacheEvent("✅ Download completed successfully", url: url)
            
            // Publish completion
            DispatchQueue.main.async { [weak self] in
                self?.isComplite = true
            }
        } else {
            // Check if it was cancelled due to user navigation
            if downloadTasks[url] == nil && downloadStartTimes[url] == nil {
                logCacheEvent("⏹️ Download was cancelled (likely due to user navigation)", url: url)
            } else {
                logCacheEvent("❌ Download failed", url: url)
            }
        }
        
        // Process next item in queue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.processNextInQueue()
        }
    }
    
    /// Cancel all downloads and clear queue
    func cancelAllDownloads() {
        lock.lock()
        defer { lock.unlock() }
        
        // Cancel current download
        if let currentUrl = currentlyPreloading, let task = downloadTasks[currentUrl] {
            logCacheEvent("❌ Cancelling current download", url: currentUrl)
            task.cancel()
        }
        
        // Clear all tracking
        downloadTasks.removeAll()
        downloadStartTimes.removeAll()
        currentlyPreloading = nil
        
        // Clear preload queue
        let queueCount = preloadQueue.count
        preloadQueue.removeAll()
        
        logCacheEvent("🛑 Cancelled all downloads and cleared queue (\(queueCount) items)", url: nil)
    }
    
    /// Get current preload status
    func getPreloadStatus() -> (queueCount: Int, currentlyDownloading: String?, queuedUrls: [String]) {
        lock.lock()
        defer { lock.unlock() }
        
        return (
            queueCount: preloadQueue.count,
            currentlyDownloading: currentlyPreloading,
            queuedUrls: preloadQueue
        )
    }
    
    // MARK: - Existing Methods (Updated)
    
    /// Cancel current download operations
    func cancelCurrentDownloads() {
        cancelAllDownloads()
    }
    
    /// Clear all cached items and files
    func clearCache() {
        lock.lock()
        defer { lock.unlock() }
        
        cancelAllDownloads()
        let cacheCount = cachedVideos.count
        
        // Delete all cached files
        for (_, localURL) in cachedVideos {
            try? fileManager.removeItem(at: localURL)
        }
        
        cachedVideos.removeAll()
        cache.removeAll()
        cacheOrder.removeAll()
        
        logCacheEvent("🗑️ Cache cleared (\(cacheCount) files deleted)", url: nil)
    }
    
    /// Get cache status for debugging
    func getCacheStatus() -> String {
        lock.lock()
        defer { lock.unlock() }
        
        let cacheInfo = cachedVideos.keys.map { url in
            let fileName = getVideoFileName(from: url)
            let localURL = cachedVideos[url]!
            let fileSize = getFileSize(localURL)
            return "\(fileName) (\(fileSize))"
        }.joined(separator: ", ")
        
        let queueInfo = preloadQueue.map { url in
            getVideoFileName(from: url)
        }.joined(separator: ", ")
        
        let currentDownload = currentlyPreloading.map { url in
            let fileName = getVideoFileName(from: url)
            let progress = downloadTasks[url]?.progress.fractionCompleted ?? 0
            return "\(fileName) (\(Int(progress * 100))%)"
        } ?? "None"
        
        return """
        📊 CACHE STATUS:
        - Cached files (\(cachedVideos.count)/\(maxCacheSize)): [\(cacheInfo)]
        - Currently downloading: \(currentDownload)
        - Preload queue (\(preloadQueue.count)): [\(queueInfo)]
        - Preload distance: \(CacheConfiguration.preloadDistance)
        - Cache directory: \(cacheDirectory.path)
        """
    }
    
    /// Force clear stuck downloads
    func clearStuckOperations() {
        logCacheEvent("🔧 Force clearing stuck downloads", url: nil)
        cancelAllDownloads()
        logCacheEvent("✅ Cleared all stuck downloads", url: nil)
    }
    
    // MARK: - Private Methods (Existing)
    
    private func loadExistingCache() {
        // Load any existing cached files from previous app sessions
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else { return }
        
        for fileURL in files {
            let fileName = fileURL.lastPathComponent
            if let originalURL = extractOriginalURL(from: fileName) {
                cachedVideos[originalURL] = fileURL
                cacheOrder.append(originalURL)
                logCacheEvent("📂 Loaded existing cache file", url: originalURL)
            }
        }
        
        // Clean up if we exceed max cache size
        cleanupOldFiles()
    }
    
    private func generateLocalFileName(from url: String) -> String {
        let hash = url.hash
        let pathExtension = URL(string: url)?.pathExtension ?? "mp4"
        return "video_\(abs(hash)).\(pathExtension)"
    }
    
    private func extractOriginalURL(from fileName: String) -> String? {
        return nil
    }
    
    private func getFileSize(_ url: URL) -> String {
        guard let attributes = try? fileManager.attributesOfItem(atPath: url.path),
              let size = attributes[.size] as? Int64 else {
            return "unknown"
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    private func updateCacheOrder(for url: String) {
        cacheOrder.removeAll { $0 == url }
        cacheOrder.insert(url, at: 0)
    }
    
    private func cleanupOldFiles() {
        while cacheOrder.count > maxCacheSize {
            if let oldestUrl = cacheOrder.last {
                if let localURL = cachedVideos[oldestUrl] {
                    try? fileManager.removeItem(at: localURL)
                }
                cachedVideos.removeValue(forKey: oldestUrl)
                cache.removeValue(forKey: oldestUrl)
                cacheOrder.removeLast()
                logCacheEvent("🗑️ Removed old cached file (LRU)", url: oldestUrl)
            }
        }
    }
    
    // MARK: - Logging
    
    private func logCacheEvent(_ message: String, url: String?) {
        guard CacheConfiguration.enableLogging else { return }
        
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        let urlSuffix = url.map { " | \(getVideoFileName(from: $0))" } ?? ""
        
        print("[\(timestamp)] 🎥 CACHE: \(message)\(urlSuffix)")
    }
    
    private func getVideoFileName(from url: String) -> String {
        guard let url = URL(string: url) else { return "unknown" }
        let fileName = url.lastPathComponent
        return fileName.isEmpty ? url.absoluteString.suffix(30).description : fileName
    }
}

// MARK: - URLSessionDownloadDelegate
extension VideoCacheManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let originalURL = downloadTask.originalRequest?.url?.absoluteString else {
            logCacheEvent("❌ Could not get original URL from download task", url: nil)
            onDownloadCompleted(url: "", success: false)
            return
        }
        
        logCacheEvent("📥 Download finished, moving file...", url: originalURL)
        
        let localFileName = generateLocalFileName(from: originalURL)
        let destinationURL = cacheDirectory.appendingPathComponent(localFileName)
        
        do {
            // Remove existing file if it exists
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
                logCacheEvent("🗑️ Removed existing cached file", url: originalURL)
            }
            
            // Move downloaded file to cache directory
            try fileManager.moveItem(at: location, to: destinationURL)
            logCacheEvent("📂 File moved to: \(destinationURL.lastPathComponent)", url: originalURL)
            
            // Calculate download duration
            let downloadDuration = downloadStartTimes[originalURL].map { Date().timeIntervalSince($0) } ?? 0
            
            lock.lock()
            // Store in cache
            cachedVideos[originalURL] = destinationURL
            updateCacheOrder(for: originalURL)
            
            // Clean up old files if necessary
            cleanupOldFiles()
            lock.unlock()
            
            // Clean up tracking
            downloadTasks.removeValue(forKey: originalURL)
            downloadStartTimes.removeValue(forKey: originalURL)
            
            let fileSize = getFileSize(destinationURL)
            logCacheEvent("✅ Download completed in \(String(format: "%.2f", downloadDuration))s (\(fileSize)) - Cache size: \(cachedVideos.count)/\(maxCacheSize)", url: originalURL)
            
            // Notify completion and start next download
            onDownloadCompleted(url: originalURL, success: true)
            
        } catch {
            logCacheEvent("❌ Failed to move downloaded file: \(error.localizedDescription)", url: originalURL)
            onDownloadCompleted(url: originalURL, success: false)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let originalURL = downloadTask.originalRequest?.url?.absoluteString else { return }
        
        if totalBytesExpectedToWrite > 0 {
            let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * 100
            let downloadedMB = Double(totalBytesWritten) / 1024 / 1024
            let totalMB = Double(totalBytesExpectedToWrite) / 1024 / 1024
            
            // Log progress every 25%
            let progressInt = Int(progress)
            if progressInt % 25 == 0 && progressInt > 0 {
                logCacheEvent("📊 Download progress: \(String(format: "%.1f", progress))% (\(String(format: "%.1f", downloadedMB))MB/\(String(format: "%.1f", totalMB))MB)", url: originalURL)
            }
        } else {
            // If we don't know total size, log bytes downloaded
            let downloadedMB = Double(totalBytesWritten) / 1024 / 1024
            if CacheConfiguration.enableProgressLogging {
                logCacheEvent("📊 Downloaded: \(String(format: "%.1f", downloadedMB))MB", url: originalURL)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let originalURL = task.originalRequest?.url?.absoluteString else { return }
        
        if let error = error {
            // Check if it's a cancellation error
            if (error as NSError).code == NSURLErrorCancelled {
                logCacheEvent("⏹️ Download cancelled (user navigated to this video)", url: originalURL)
            } else {
                logCacheEvent("❌ Download failed: \(error.localizedDescription)", url: originalURL)
            }
            onDownloadCompleted(url: originalURL, success: false)
        } else {
            logCacheEvent("✅ Download task completed", url: originalURL)
        }
        
        // Clean up tracking
        downloadTasks.removeValue(forKey: originalURL)
        downloadStartTimes.removeValue(forKey: originalURL)
    }
}

// MARK: - Helper Extensions
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct CacheConfiguration {
    static var maxCacheSize: Int = 10
    static var enableCaching: Bool = true
    
    // Logging configuration
    static var enableLogging: Bool = true
    static var enableProgressLogging: Bool = true
    
    // Download configuration
    static var downloadTimeout: TimeInterval = 60.0 // seconds
    static var maxConcurrentDownloads: Int = 1
    
    // You can add more configuration options here
    static var preloadDistance: Int = 3 // How many videos ahead to preload
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
