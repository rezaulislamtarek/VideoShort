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
            playVideoOnChangeOfPosition(postId: id)
        }
        .onAppear{
            playInitialVideoIfNecessary()
        }
    }
    
    
    func playInitialVideoIfNecessary() {
        guard let post = viewModel.posts.first,
              player.currentItem == nil  else { return }
        currentId = post.id
        let playerItem = AVPlayerItem(url: URL(string: post.videoUrl)!)
        player.replaceCurrentItem(with: playerItem)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            player.play()
        }
    }
    
    func playVideoOnChangeOfPosition(postId: String?) {
        guard let currentPost = viewModel.posts.first(where: {$0.id == postId}) else { return }
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            currentId = currentPost.id
        //}
        player.replaceCurrentItem(with: nil)
        let playerItem = AVPlayerItem(url: URL(string: currentPost.videoUrl)!)
        player.replaceCurrentItem(with: playerItem)
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        ShortViewiOS17Plus()
    } else {
        // Fallback on earlier versions
    }
}
