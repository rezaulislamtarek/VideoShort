//
//  ShortView.swift
//  VideoShort
//
//  Created by Rezaul Islam on 5/27/25.
//

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
        
        // Cache next video if available
        cacheNextVideoIfAvailable(currentIndex: 0)
    }
    
    func playVideoOnChangeOfPosition(postId: String?, currentIndex: Int) {
        guard let currentPost = viewModel.posts.first(where: {$0.id == postId}) else { return }
        
        currentId = currentPost.id
        player.replaceCurrentItem(with: nil)
        
        print("🎬 PLAYER: Switching to video at index \(currentIndex) - \(getVideoFileName(from: currentPost.videoUrl))")
        
        // Get video item from cache or create new one
        let playerItem = cacheManager.getVideoItem(for: currentPost.videoUrl)
        player.replaceCurrentItem(with: playerItem)
        
        // Cache next video if available
        cacheNextVideoIfAvailable(currentIndex: currentIndex)
    }
    
    // MARK: - Private Caching Methods
    
    private func cacheNextVideoIfAvailable(currentIndex: Int) {
        let nextIndex = currentIndex + 1
        
        // Check if next video exists
        guard nextIndex < viewModel.posts.count else {
            print("📱 PLAYER: No next video to cache (reached end)")
            return
        }
        
        let nextVideoUrl = viewModel.posts[nextIndex].videoUrl
        print("📱 PLAYER: Requesting cache for next video (index \(nextIndex)) - \(getVideoFileName(from: nextVideoUrl))")
        
        // Cache next video asynchronously
        cacheManager.cacheNextVideo(url: nextVideoUrl)
    }
    
    private func getVideoFileName(from url: String) -> String {
        guard let url = URL(string: url) else { return "unknown" }
        let fileName = url.lastPathComponent
        return fileName.isEmpty ? url.absoluteString.suffix(20).description : String(fileName.prefix(20))
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        ShortViewiOS17Plus()
    } else {
        // Fallback on earlier versions
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        ShortViewiOS17Plus()
    } else {
        // Fallback on earlier versions
    }
}
