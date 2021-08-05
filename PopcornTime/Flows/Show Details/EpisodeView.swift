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
    var episode: Episode
    let imageUrl: String
    
    init(episode: Episode) {
        self.episode = episode
        self.imageUrl = episode.smallBackgroundImage ?? ""
    }
    
    var body: some View {
        VStack {
            KFImage(URL(string: imageUrl))
                .resizable()
//                .loadImmediately()
                .placeholder {
                    Image("Episode Placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .aspectRatio(contentMode: .fill)
//                .cornerRadius(10)
//                .shadow(radius: 5)
                        .frame(width: 310, height: 174)
                .padding(.bottom, 5)
                .clipped()
            Text("\(episode.episode). " + episode.title)
                .lineLimit(1)
        }
        .frame(width: 310, height: 215)
    }
}

struct EpisodeView_Previews: PreviewProvider {
    static var previews: some View {
        let episode = Episode(JSON: showEpisodesJSON[0])!
        EpisodeView(episode: episode)
    }
}
