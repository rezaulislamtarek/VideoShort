//
//  ContentView.swift
//  VideoShort
//
//  Created by Rezaul Islam on 5/27/25.
//

import SwiftUI

struct ShortsView: View {
    var body: some View {
        if #available(iOS 17.0, *){
            ShortViewiOS17Plus()
        }else{
            ShortViewiOS16()
        }
       
    }
}

#Preview {
    ShortsView()
}
