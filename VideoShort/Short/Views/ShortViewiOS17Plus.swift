//
//  ShortView.swift
//  VideoShort
//
//  Created by Rezaul Islam on 5/27/25.
//

import SwiftUI
import AVKit

@available(iOS 17.0, *)
struct ShortViewiOS17Plus: View {
    
    @StateObject var viewModel = ShortViewModel()
    @State private var player = AVPlayer()
    @State var currentIndex : Int? = 0
    @State var currentId : String?
    
    // Cache manager
    private let cacheManager = VideoCacheManager.shared
    
    var body: some View {
        ScrollView(showsIndicators: false){
            LazyVStack(spacing : 0) {
                ForEach(Array(viewModel.posts.enumerated()), id: \.element.id){ index, post in
                    FeedCell(post: post, player: player, currentVisibleIndex: $currentId)
                        .frame(maxWidth: .infinity)
                        .containerRelativeFrame(.vertical)
                        .id(index)
                }
            }
        }
        .ignoresSafeArea()
        .scrollTargetLayout()
        .scrollTargetBehavior(.paging)
        .scrollBounceBehavior(.basedOnSize)
        .scrollPosition(id : $currentIndex)
        .onChange(of: currentIndex!) { newValue in
            let id = viewModel.posts[newValue].id
            playVideoOnChangeOfPosition(postId: id, currentIndex: newValue)
        }
        .onAppear{
            playInitialVideoIfNecessary()
        }
        .onDisappear {
            // Clean up when view disappears
            cacheManager.clearStuckOperations()
        }
        // Add debugging gesture (long press to print cache status)
        .onLongPressGesture {
            print(cacheManager.getCacheStatus())
            
            // Also print preload status
            let status = cacheManager.getPreloadStatus()
            print("📋 PRELOAD STATUS:")
            print("   Queue count: \(status.queueCount)")
            print("   Currently downloading: \(status.currentlyDownloading ?? "None")")
            print("   Queued URLs: \(status.queuedUrls.map { getVideoFileName(from: $0) })")
        }
        // Listen for download completions to show feedback
        .onReceive(cacheManager.$isComplite) { completed in
            if completed {
                print("🎉 A video download completed! Starting next in queue...")
            }
        }
    }
    
    func playInitialVideoIfNecessary() {
        guard let post = viewModel.posts.first,
              player.currentItem == nil else { return }
        
        currentId = post.id
        print("🎬 PLAYER: Playing initial video - \(getVideoFileName(from: post.videoUrl))")
        
        // Get video item from cache or create new one
        let playerItem = cacheManager.getVideoItem(for: post.videoUrl)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
        // Start preloading from current position
        startPreloadingFromCurrentPosition(currentIndex: 0)
    }
    
    func playVideoOnChangeOfPosition(postId: String?, currentIndex: Int) {
        guard let currentPost = viewModel.posts.first(where: {$0.id == postId}) else { return }
        
        currentId = currentPost.id
        player.replaceCurrentItem(with: nil)
        
        print("🎬 PLAYER: Switching to video at index \(currentIndex) - \(getVideoFileName(from: currentPost.videoUrl))")
        
        // Check if this video was downloading or queued
        let preloadStatus = cacheManager.getPreloadStatus()
        let wasInQueue = preloadStatus.queuedUrls.contains(currentPost.videoUrl)
        let wasDownloading = preloadStatus.currentlyDownloading == currentPost.videoUrl
        
        if wasInQueue || wasDownloading {
            let status = wasDownloading ? "downloading" : "queued"
            print("🎯 PRIORITY: Video was \(status), canceling for immediate playback")
        }
        
        // Get video item from cache or create new one (this handles the cancellation internally)
        let playerItem = cacheManager.getVideoItem(for: currentPost.videoUrl)
        player.replaceCurrentItem(with: playerItem)
        
        // Update preload queue based on new position
        startPreloadingFromCurrentPosition(currentIndex: currentIndex)
        
        // Show updated queue status
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let newStatus = cacheManager.getPreloadStatus()
            if newStatus.queueCount > 0 {
                print("📋 QUEUE: Restarted with \(newStatus.queueCount) videos")
            }
        }
    }
    
    // MARK: - Private Preloading Methods
    
    private func startPreloadingFromCurrentPosition(currentIndex: Int) {
        // Get all video URLs from posts
        let allVideoUrls = viewModel.posts.map { $0.videoUrl }
        
        // Start preloading from current position
        cacheManager.cacheVideosFromCurrentPosition(
            currentIndex: currentIndex,
            videoUrls: allVideoUrls
        )
        
        print("📱 PLAYER: Updated preload queue from index \(currentIndex)")
        
        // Log what we're planning to cache
        let preloadStatus = cacheManager.getPreloadStatus()
        if preloadStatus.queueCount > 0 {
            let queuedFiles = preloadStatus.queuedUrls.prefix(3).map { getVideoFileName(from: $0) }
            print("📋 PRELOAD: Next \(preloadStatus.queueCount) videos queued: \(queuedFiles.joined(separator: ", "))\(preloadStatus.queueCount > 3 ? "..." : "")")
        }
    }
    
    private func getVideoFileName(from url: String) -> String {
        guard let url = URL(string: url) else { return "unknown" }
        let fileName = url.lastPathComponent
        return fileName.isEmpty ? url.absoluteString.suffix(20).description : String(fileName.prefix(20))
    }
    
    // MARK: - Debug Methods (Optional)
    
    private func showPreloadDebugInfo() {
        let status = cacheManager.getPreloadStatus()
        print("""
        
        🔍 DETAILED PRELOAD DEBUG:
        ========================
        📱 Current Index: \(currentIndex ?? -1)
        📋 Queue Count: \(status.queueCount)
        🔄 Currently Downloading: \(status.currentlyDownloading ?? "None")
        📝 Preload Distance: \(CacheConfiguration.preloadDistance)
        
        📋 Queued Videos:
        \(status.queuedUrls.enumerated().map { "   \($0.offset + 1). \(getVideoFileName(from: $0.element))" }.joined(separator: "\n"))
        
        ========================
        
        """)
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        ShortViewiOS17Plus()
    } else {
        // Fallback on earlier versions
    }
}
