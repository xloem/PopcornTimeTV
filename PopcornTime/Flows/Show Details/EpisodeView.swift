//
//  EpisodeView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 04.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import Kingfisher

struct EpisodeView: View {
    struct Theme {
        let imageWidth: CGFloat = value(tvOS: 310, macOS: 217)
        let imageHeight: CGFloat = value(tvOS: 174, macOS: 121)
    }
    let theme = Theme()
    
    var episode: Episode
    @EnvironmentObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        VStack {
            KFImage(URL(string: episode.smallBackgroundImage ?? ""))
                .resizable()
                .loadImmediately()
                .placeholder {
                    Image("Episode Placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .aspectRatio(contentMode: .fill)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: theme.imageWidth, height: theme.imageHeight)
                .overlay(alignment: .bottomTrailing) {
                    if episode.isWatched {
                        Image("Episode Watched Indicator")
                    }
                }
                .padding(.bottom, 5)
                .clipped()
            Text("\(episode.episode). " + episode.title)
                .lineLimit(1)
        }
        .onAppear {
            viewModel.loadImageIfMissing(episode: episode)
        }
    }
}

struct EpisodeView_Previews: PreviewProvider {
    static var previews: some View {
        let episode = Episode(JSON: showEpisodesJSON[0])!
        EpisodeView(episode: episode)
            .environmentObject(ShowDetailsViewModel(show: episode.show!))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .background(.blue)
    }
}
