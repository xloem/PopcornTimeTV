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
    var nextEpisode: NextEpisode?

    indirect enum State_ {
        case none
        case preload(PreloadTorrentViewModel)
        case play(PlayerViewModel)
        case next(TorrentPlayerView)
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
            PlayerView(upNextView: upNextView(playerModel: playerModel))
                .environmentObject(playerModel)
                .background(Color.black)
        case .next(let nextView):
            nextView
        }
    }
    
    func load() {
        self.state = .preload(PreloadTorrentViewModel(torrent: torrent, media: media, onReadyToPlay: { playerModel in
            self.state = .play(playerModel)
        }))
    }
    
    @ViewBuilder
    func upNextView(playerModel: PlayerViewModel) -> UpNextView? {
        if let nextEpisode = nextEpisode,
           let episode = self.nextEpisode?.episode,
           let torrent = episode.torrents.first(where: {$0.quality == self.torrent.quality}) {
            UpNextView(episode: episode, show: nextEpisode.show, playerModel: playerModel) {
                self.state = .next(TorrentPlayerView(torrent: torrent, media: episode, nextEpisode: nextEpisode.next()))
            }
        }
    }
}

struct MediaPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        TorrentPlayerView(torrent: Torrent(), media: Movie.dummy())
            .preferredColorScheme(.dark)
    }
}
