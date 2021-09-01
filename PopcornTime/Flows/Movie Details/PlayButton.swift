//
//  PlayButton.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 21.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import Combine

struct PlayButton: View {
    struct Theme {
        let buttonWidth: CGFloat = value(tvOS: 142, macOS: 100)
        let buttonHeight: CGFloat = value(tvOS: 115, macOS: 81)
    }
    let theme = Theme()
    
    var viewModel: PlayButtonModel
    @State var showPlayer = false
    
    var body: some View {
        SelectTorrentQualityButton(media: viewModel.media, action: { torrent in
            self.viewModel.torrent = torrent
            self.showPlayer = true
        }, label: {
            VStack {
                VisualEffectBlur() {
                    Image("Play")
                }
                Text("Play".localized)
            }
        })
        .frame(width: theme.buttonWidth, height: theme.buttonHeight)
        .fullScreenContent(isPresented: $showPlayer, title: viewModel.media.title) {
            torrentView()
        }
    }
    
    @ViewBuilder
    func torrentView() -> some View {
        if let torrent = viewModel.torrent {
            TorrentPlayerView(torrent: torrent, media: viewModel.media)
        }
    }
}

struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayButton(viewModel: PlayButtonModel(media: Movie.dummy()))
            .buttonStyle(TVButtonStyle())
            .padding(40)
            .previewLayout(.fixed(width: 300, height: 300))
            .preferredColorScheme(.dark)
    }
}
