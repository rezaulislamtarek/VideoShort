//
//  ShortViewModel.swift
//  VideoShort
//
//  Created by Rezaul Islam on 5/27/25.
//

import Foundation
 
 
final class ShortViewModel : ObservableObject  {
    @Published var posts = [Post]()
    
    
    init( ) {
         
        fetchPosts()
    }
    
    private func fetchPosts() {
        posts = Post.posts
    }
    
     
}
