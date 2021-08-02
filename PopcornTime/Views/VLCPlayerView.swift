//
//  VLCPlayerView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 21.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import TVVLCKit

struct VLCPlayerView: UIViewRepresentable {
    var mediaplayer = VLCMediaPlayer()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        mediaplayer.drawable = view
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        mediaplayer.drawable = uiView
    }
}
