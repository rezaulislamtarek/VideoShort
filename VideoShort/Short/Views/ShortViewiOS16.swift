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
                playVideoOnChangeOfPosition(postId: id)
            }
            .onAppear{
                playInitialVideoIfNecessary()
            }
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
    ShortViewiOS16()
}
