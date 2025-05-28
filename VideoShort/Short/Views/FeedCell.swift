//
//  FeedCell.swift
//  VideoShort
//
//  Created by Rezaul Islam on 5/27/25.
//

//
//  FeedCell.swift
//  VideoShort
//
//  Created by Rezaul Islam on 5/27/25.
//

import SwiftUI
import AVKit
import Kingfisher

struct FeedCell: View {
    let post: Post
    var player: AVPlayer
    @Binding var currentVisibleId: String?
    @State private var isBuffering: Bool = false
    @State private var showPlayButton: Bool = false
    
    init(post: Post, player: AVPlayer, currentVisibleIndex: Binding<String?>) {
        self.post = post
        self.player = player
        self._currentVisibleId = currentVisibleIndex
    }
    
    var body: some View {
        ZStack {
            
            thumbNailSection
            
            if currentVisibleId == post.id {
                CustomVideoPlayer(player: player, isBuffering: $isBuffering)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: currentVisibleId)
                    .onReceive(player.publisher(for: \.timeControlStatus)) { status in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showPlayButton = (status == .paused && !isBuffering)
                        }
                    }
            }
            
            // Buffering indicator - only show when actually buffering
            if isBuffering && currentVisibleId == post.id {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 80, height: 80)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: isBuffering)
            }
            
            // Play button - show when paused (but not buffering)
            if showPlayButton && currentVisibleId == post.id && !isBuffering {
                Button(action: {
                    player.play()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: showPlayButton)
            }
            
            Color.clear
                .background(
                    LinearGradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0.5), Color.clear,Color.clear,Color.clear, Color.clear, Color.black.opacity(0.5), Color.black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                )
            
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    shortInfoSection
                    
                    Spacer()
                    
                    shortsRightActionSection
                    
                }.padding(.bottom, 80)
                
            }.padding()
        }.onTapGesture {
            handleVideoTap()
        }
    }
    
    private func handleVideoTap() {
        switch player.timeControlStatus {
        case .paused:
            player.play()
        case .waitingToPlayAtSpecifiedRate:
            // Don't do anything while buffering
            break
        case .playing:
            player.pause()
        @unknown default:
            break
        }
    }
}

extension FeedCell {
    private var shortInfoSection: some View {
        VStack(alignment: .leading) {
            HStack{
                KFImage(URL(string: post.userProfilePictureUrl))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                Text("@\(post.username)")
                    .fontWeight(.semibold)
            }
            
            Text("\(post.caption)")
                .fontWeight(.semibold)
        }.font(.subheadline)
            .foregroundStyle(.white)
    }
    
    
    private var shortsRightActionSection: some View {
        VStack(spacing: 28) {
            
            Circle()
                .frame(width: 48, height: 48)
                .foregroundStyle(.gray)
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .frame(width: 28,height: 28)
                        .foregroundStyle(.white)
                    
                    Text("\(post.likeCount)")
                        .font(.footnote)
                        .foregroundStyle(.white)
                }
            }
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "ellipsis.bubble.fill")
                        .resizable()
                        .frame(width: 28,height: 28)
                        .foregroundStyle(.white)
                    
                    Text("\(post.commentCount)")
                        .font(.footnote)
                        .foregroundStyle(.white)
                }
            }
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "bookmark.fill")
                        .resizable()
                        .frame(width: 22,height: 28)
                        .foregroundStyle(.white)
                    
                    Text("\(Int(post.likeCount / 2))")
                        .font(.footnote)
                        .foregroundStyle(.white)
                }
            }
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .resizable()
                        .frame(width: 28,height: 28)
                        .foregroundStyle(.white)
                    
                    
                    Text("\(Int(post.likeCount / 3))")
                        .font(.footnote)
                        .foregroundStyle(.white)
                }
                
            }
        }
    }
    
    private var thumbNailSection : some View {
        KFImage(URL(string: post.thumbnailUrl))
            .resizable()
            .scaledToFit()
            //.opacity(currentVisibleId == post.id ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: currentVisibleId)
    }
}

#Preview {
    FeedCell( post: Post.posts.first! , player: AVPlayer(), currentVisibleIndex: .constant("0") )
}
