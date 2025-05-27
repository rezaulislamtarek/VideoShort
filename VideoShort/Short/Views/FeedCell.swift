//
//  FeedCell.swift
//  VideoShort
//
//  Created by Rezaul Islam on 5/27/25.
//

import SwiftUI

import SwiftUI
import AVKit
import Kingfisher

struct FeedCell: View {
    let post: Post
    var player: AVPlayer
    @Binding var currentVisibleId: String?
    @State private var isBuffering: Bool = true
    
    init(post: Post, player: AVPlayer, currentVisibleIndex: Binding<String?>) {
        self.post = post
        self.player = player
        self._currentVisibleId = currentVisibleIndex
    }
    
    var body: some View {
        ZStack {
            
            KFImage(URL(string: post.thumbnailUrl))
                .resizable()
                .scaledToFit()
                //.opacity(currentVisibleId == post.id ? 0 : 1)
                .animation(.easeInOut(duration: 0.3), value: currentVisibleId)
            
            if currentVisibleId == post.id {
                CustomVideoPlayer(player: player, isBuffering: $isBuffering)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: currentVisibleId)
            }
            
            if isBuffering {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    //.scaleEffect(1)
            }
            
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("@test.user")
                            .fontWeight(.semibold)
                        
                        Text("Rocket ship preparing to take off")
                            .fontWeight(.semibold)
                    }.font(.subheadline)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
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
                                
                                Text("12")
                                    .font(.footnote)
                                    .foregroundStyle(.white)
                                    .bold()
                            }
                        }
                        
                        Button {
                            
                        } label: {
                            VStack {
                                Image(systemName: "ellipsis.bubble.fill")
                                    .resizable()
                                    .frame(width: 28,height: 28)
                                    .foregroundStyle(.white)
                                
                                Text("27")
                                    .font(.footnote)
                                    .foregroundStyle(.white)
                                    .bold()
                            }
                        }
                        
                        Button {
                            
                        } label: {
                            VStack {
                                Image(systemName: "bookmark.fill")
                                    .resizable()
                                    .frame(width: 22,height: 28)
                                    .foregroundStyle(.white)
                                
                                Text("2")
                                    .font(.footnote)
                                    .foregroundStyle(.white)
                                    .bold()
                            }
                        }
                        
                        Button {
                            
                        } label: {
                            VStack {
                                Image(systemName: "arrowshape.turn.up.right.fill")
                                    .resizable()
                                    .frame(width: 28,height: 28)
                                    .foregroundStyle(.white)
                                
                                
                                Text("30")
                                    .font(.footnote)
                                    .foregroundStyle(.white)
                                    .bold()
                            }
                            
                        }
                    }
                }.padding(.bottom, 80)
                
            }.padding()
        }.onTapGesture {
            switch player.timeControlStatus {
            case .paused:
                player.play()
            case .waitingToPlayAtSpecifiedRate:
                break
            case .playing:
                player.pause()
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    FeedCell( post: Post.posts.first! , player: AVPlayer(), currentVisibleIndex: .constant("0") )
}
