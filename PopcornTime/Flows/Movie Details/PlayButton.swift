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
    let theme = Theme()
    
    @State var media: Media
    @State var showTorrent: PlayTorrent?
    
    struct PlayTorrent: Identifiable, Equatable {
        var id: String  { torrent.id }
        var torrent: Torrent
    }
    
    var body: some View {
        SelectTorrentQualityButton(media: media, action: { torrent in
            self.showTorrent = PlayTorrent(torrent: torrent)
        }, label: {
            VStack {
                VisualEffectBlur() {
                    Image("Play")
                }
                Text("Play")
            }
        })
        .frame(width: theme.buttonWidth, height: theme.buttonHeight)
        .fullScreenContent(item: $showTorrent, title: media.title) { item in
            TorrentPlayerView(torrent: item.torrent, media: media)
        }
    }
}

extension PlayButton {
    struct Theme {
        let buttonWidth: CGFloat = value(tvOS: 142, macOS: 100)
        let buttonHeight: CGFloat = value(tvOS: 115, macOS: 81)
    }
}

struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayButton(media: Movie.dummy())
            .buttonStyle(TVButtonStyle())
            .padding(40)
            .previewLayout(.fixed(width: 300, height: 300))
            .preferredColorScheme(.dark)
    }
}
