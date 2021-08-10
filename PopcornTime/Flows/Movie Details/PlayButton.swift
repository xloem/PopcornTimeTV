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
    var viewModel: MovieDetailsViewModel
    
    @StateObject var buttonModel = PlayButtonModel()
    @State var torrent: Torrent?
    @State var showPlayer = false
    
    var movie: Movie {
        return viewModel.movie
    }
    var onFocus: () -> Void = {}
    
    var body: some View {
        SelectTorrentQualityButton(media: movie, action: { torrent in
            self.torrent = torrent
            self.buttonModel.torrent = torrent
            self.showPlayer = true
        }, label: {
//            navigationLink
//                .hidden()
            
            VStack {
                VisualEffectBlur() {
                    Image("Play")
                }
                Text("Play".localized)
            }
        }, onFocus: onFocus)
        .frame(width: 142, height: 115)
        .fullScreenCover(isPresented: $showPlayer) {
            torrentView()
        }
    }
    
    @ViewBuilder
    var navigationLink: some View {
        if let torrent = torrent {
            NavigationLink(isActive: $showPlayer,
                           destination: { TorrentPlayerView(torrent: torrent, media: movie) },
                           label: { EmptyView() })
        }
    }
    
    @ViewBuilder
    func torrentView() -> some View {
        if let torrent = buttonModel.torrent {
            TorrentPlayerView(torrent: torrent, media: movie)
        }
    }
}

struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayButton(viewModel: MovieDetailsViewModel(movie: Movie.dummy()))
            .buttonStyle(TVButtonStyle())
            .padding(40)
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
