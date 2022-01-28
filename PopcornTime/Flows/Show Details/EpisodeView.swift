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
    var isSelected: Bool // on iOS/mac
    @Environment(\.isFocused) var isFocused // on TV
    
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
                .frame(width: theme.imageWidth, height: theme.imageHeight)
                .clipped()
                .overlay(alignment: .bottomLeading) {
                    if showAirdate {
                        HStack {
                            airDateLabel
                                .padding([.top, .bottom, .trailing], 8)
                            Spacer()
                        }
                        .background {
                            LinearGradient(gradient: Gradient(colors: [.clear, .init(white: 0.0, opacity: 0.5)]), startPoint: .top, endPoint: .bottom)
                        }
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if episode.isWatched {
                        Image("Episode Watched Indicator")
                    }
                }
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.bottom, 5)
            Text("\(episode.episode). " + episode.title)
                .lineLimit(1)
        }
        .onAppear {
            viewModel.loadImageIfMissing(episode: episode)
        }
    }
    
    @ViewBuilder
    var airDateLabel: some View {
        let airDateString = DateFormatter.localizedString(from: episode.firstAirDate, dateStyle: .medium, timeStyle: .none)
        Text(airDateString)
            .font(.caption2)
            .foregroundColor(.init(white: 1.0, opacity: 0.92))
            .shadow(radius: 4)
            .padding(.leading, 10)
    }
    
    var showAirdate: Bool {
#if os(tvOS)
        return isFocused
#else
        return isSelected
#endif
    }
}

struct EpisodeView_Previews: PreviewProvider {
    static var previews: some View {
        let episode = Episode(JSON: showEpisodesJSON[0])!
        Group {
            EpisodeView(episode: episode, isSelected: true)
            EpisodeView(episode: episode, isSelected: false)
        }
            .environmentObject(ShowDetailsViewModel(show: episode.show!))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .background(.blue)
    }
}
