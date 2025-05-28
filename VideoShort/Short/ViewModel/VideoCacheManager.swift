import Foundation
import AVFoundation

class VideoCacheManager: NSObject, ObservableObject {
    static let shared = VideoCacheManager()
    
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
        self.downloadQueue.maxConcurrentOperationCount = CacheConfiguration.maxConcurrentDownloads // Sequential downloading
        self.downloadQueue.qualityOfService = .background
        loadExistingCache()
    }
    
    init(maxCacheSize: Int = CacheConfiguration.maxCacheSize) {
        self.maxCacheSize = maxCacheSize
        super.init()
        self.downloadQueue.maxConcurrentOperationCount = CacheConfiguration.maxConcurrentDownloads // Sequential downloading
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
        
        logCacheEvent("🌐 Playing from URL (not cached)", url: url)
        return AVPlayerItem(url: URL(string: url)!)
    }
    
    /// Cache next video by downloading the file
    func cacheNextVideo(url: String) {
        // Cancel any existing downloads for different URLs
        cancelCurrentDownloads()
        
        // Don't cache if already cached
        lock.lock()
        let isAlreadyCached = cachedVideos[url] != nil
        lock.unlock()
        
        if isAlreadyCached {
            logCacheEvent("✅ Video already cached to file", url: url)
            return
        }
        
        // Check if already downloading
        if downloadTasks[url] != nil {
            logCacheEvent("⏳ Video already downloading", url: url)
            return
        }
        
        guard let videoURL = URL(string: url) else {
            logCacheEvent("❌ Invalid URL for caching", url: url)
            return
        }
        
        logCacheEvent("🔍 Testing URL accessibility: \(url)", url: url)
        
        // Test URL first
        var request = URLRequest(url: videoURL)
        request.httpMethod = "HEAD"
        
        let testTask = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.logCacheEvent("❌ URL test failed: \(error.localizedDescription)", url: url)
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
    
    /// Cancel current download operations
    func cancelCurrentDownloads() {
        if !downloadTasks.isEmpty {
            logCacheEvent("❌ Cancelling \(downloadTasks.count) download(s)", url: nil)
            
            for (url, task) in downloadTasks {
                logCacheEvent("❌ Cancelled download", url: url)
                task.cancel()
            }
            
            downloadTasks.removeAll()
            downloadStartTimes.removeAll()
        }
    }
    
    /// Clear all cached items and files
    func clearCache() {
        lock.lock()
        defer { lock.unlock() }
        
        cancelCurrentDownloads()
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
        
        let activeDownloads = downloadTasks.keys.map { url in
            getVideoFileName(from: url)
        }.joined(separator: ", ")
        
        return """
        📊 CACHE STATUS:
        - Cached files (\(cachedVideos.count)/\(maxCacheSize)): [\(cacheInfo)]
        - Active downloads (\(downloadTasks.count)): [\(activeDownloads)]
        - Cache directory: \(cacheDirectory.path)
        """
    }
    
    /// Force clear stuck downloads
    func clearStuckOperations() {
        logCacheEvent("🔧 Force clearing stuck downloads", url: nil)
        cancelCurrentDownloads()
        logCacheEvent("✅ Cleared all stuck downloads", url: nil)
    }
    
    // MARK: - Private Methods
    
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
        // This is a simple approach - in production you might want to store a mapping file
        // For now, we can't reliably extract the original URL from the hash
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
            
        } catch {
            logCacheEvent("❌ Failed to move downloaded file: \(error.localizedDescription)", url: originalURL)
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
            logCacheEvent("❌ Download failed: \(error.localizedDescription)", url: originalURL)
        } else {
            logCacheEvent("✅ Download task completed", url: originalURL)
        }
        
        // Clean up tracking
        downloadTasks.removeValue(forKey: originalURL)
        downloadStartTimes.removeValue(forKey: originalURL)
    }
}

struct CacheConfiguration {
    static var maxCacheSize: Int = 2
    static var enableCaching: Bool = true
    
    // Logging configuration
    static var enableLogging: Bool = true
    static var enableProgressLogging: Bool = true
    
    // Download configuration
    static var downloadTimeout: TimeInterval = 60.0 // seconds
    static var maxConcurrentDownloads: Int = 1
    
    // You can add more configuration options here
    static var preloadDistance: Int = 1 // How many videos ahead to preload
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
