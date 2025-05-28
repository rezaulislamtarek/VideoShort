//
//  ShortViewiOS16.swift
//  VideoShort
//
//  Created by Rezaul Islam on 5/27/25.
//

import SwiftUI
import AVKit

struct ShortViewiOS16 : View {
    
    @StateObject var viewModel = ShortViewModel()
    @State private var player = AVPlayer()
    @State var currentIndex : Int = 0
    @State var currentId : String?
    
    // Cache manager
    private let cacheManager = VideoCacheManager.shared
    
    var body : some View {
        GeometryReader{ proxy in
            let size = proxy.size
            
            let height = size.height
            let width = size.width
            
            TabView(selection: $currentIndex){
                ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) { index, post in
                    FeedCell(post: post,player: player, currentVisibleIndex: $currentId)
                        .frame(width: width)
                        .rotationEffect(Angle(degrees: -90))
                        .tag(index)
                }
            }
            .rotationEffect(Angle(degrees: 90))
            .frame(width: height)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: width)
            .onChange(of: currentIndex) { newValue in
                let id = viewModel.posts[newValue].id
                playVideoOnChangeOfPosition(postId: id, currentIndex: newValue)
            }
            .onAppear{
                playInitialVideoIfNecessary()
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
    ShortViewiOS16()
}
