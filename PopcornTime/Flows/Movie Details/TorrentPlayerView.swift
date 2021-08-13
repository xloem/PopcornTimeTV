//
//  MediaPlayerView.swift
//  MediaPlayerView
//
//  Created by Alexandru Tudose on 03.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct TorrentPlayerView: View {
    var torrent: Torrent
    var media: Media

    #if os(tvOS) || os(iOS)
    enum State_ {
        case none
        case preload(PreloadTorrentViewModel)
        case play(PlayerViewModel)
    }
    @State var state: State_ = .none
    
    var body: some View {
        switch state {
        case .none:
            Color.black
                .onAppear{
                    load()
                }
        case .preload(let preloadModel):
            PreloadTorrentView(viewModel: preloadModel)
                .background(Color.black)
        case .play(let playerModel):
            PlayerView()
                .environmentObject(playerModel)
                .background(Color.black)
        }
    }
    
    func load() {
        self.state = .preload(PreloadTorrentViewModel(torrent: torrent, media: media, onReadyToPlay: { playerModel in
            self.state = .play(playerModel)
        }))
    }
    #else
    var body: some View {
        Text("Not implemented")
    }
    #endif
}

struct MediaPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        TorrentPlayerView(torrent: Torrent(), media: Movie.dummy())
            .preferredColorScheme(.dark)
    }
}
