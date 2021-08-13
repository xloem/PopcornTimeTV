//
//  EpisodesView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import Combine

struct EpisodesView: View {
    struct Theme {
        let episodeWidth: CGFloat = value(tvOS: 310, macOS: 217)
        let episodeHeight: CGFloat = value(tvOS: 215, macOS: 150)
        let currentEpisode: (padding: CGFloat, height: CGFloat) =
                        (padding: value(tvOS: 250, macOS: 100),
                         height: value(tvOS: 350, macOS: 250))
    }
    let theme = Theme()
    
    var show: Show
    var episodes: [Episode]
    var currentSeason: Int
    @State var currentEpisode: Episode? {
        didSet {
            downloadModel = currentEpisode.flatMap{ DownloadButtonViewModel(media: $0)}
        }
    }
    @State var downloadModel: DownloadButtonViewModel?
    
    @State var torrent: Torrent?
    @State var showPlayer = false
    
    var onFocus: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading) {
            navigationLink
                .hidden()
            titleView
            episodesCountView
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(episodes, id: \.self) { episode in
                        episodeView(episode: episode)
                    }
                }
                .padding([.top, .bottom], 20) // allow zooming to be visible
                .padding([.leading, .trailing], 90)
            }
            currentEpisodeView
            #if os(tvOS)
                .focusSection()
            #endif
        }
        #if os(tvOS)
        .fullScreenCover(isPresented: $showPlayer) {
            if let torrent = torrent, let episode = currentEpisode {
                TorrentPlayerView(torrent: torrent, media: episode)
            }
        }
        #endif
        .onChange(of: episodes) { newValue in
            if currentEpisode == nil {
                currentEpisode = newValue.first
            }
        }
    }
    
    @ViewBuilder
    var titleView: some View {
        HStack {
            Spacer()
            Text(show.title)
                .font(.title2)
            Spacer()
        }
    }
    
    @ViewBuilder
    var navigationLink: some View {
        #if os(tvOS) || os(iOS)
        if let torrent = torrent, let episode = currentEpisode {
            NavigationLink(destination: TorrentPlayerView(torrent: torrent, media: episode),
                           isActive: $showPlayer,
                           label: {
                EmptyView()
            })
        }
        #endif
    }
    
    @ViewBuilder
    func episodeView(episode: Episode) -> some View {
        SelectTorrentQualityButton(media: episode, action: { torrent in
            self.torrent = torrent
            self.currentEpisode = episode
            showPlayer = true
        }, label: {
            EpisodeView(episode: episode)
        }, onFocus: {
            currentEpisode = episode
            onFocus()
        })
        .frame(width: theme.episodeWidth, height: theme.episodeHeight)
    }
    
    @ViewBuilder
    var episodesCountView: some View {
        let localizedSeason = NumberFormatter.localizedString(from: NSNumber(value: currentSeason), number: .none)
        let seasonString = "Season".localized + " \(localizedSeason)"
        let count = episodes.count
        let isSingular = count == 1
        let numberOfEpisodes = "\(NumberFormatter.localizedString(from: NSNumber(value: count), number: .none)) \(isSingular ? "Episode".localized : "Episodes".localized)"
        
        Text("\(seasonString) (\(numberOfEpisodes.lowercased()))")
            .font(.callout)
            .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
            .padding(.leading, 90)
            .padding(.top, 14)
    }
    
    @ViewBuilder
    var currentEpisodeView: some View {
        if let episode = currentEpisode, let downloadModel = downloadModel {
            let airDateString = DateFormatter.localizedString(from: episode.firstAirDate, dateStyle: .medium, timeStyle: .none)
            let showGenre = episode.show?.genres.first?.localizedCapitalized.localized ?? ""
            let infoText = "\(airDateString) \n \(showGenre)"
            
            HStack() {
                VStack {
                    Text(infoText)
                        .font(.callout)
                        .multilineTextAlignment(.trailing)
                }
                VStack(alignment: .leading) {
                    Text("\(episode.episode). " + episode.title)
                        .font(.headline)
                    HStack {
                        Text(episode.summary)
                            .multilineTextAlignment(.leading)
//                            .lineLimit(6)
                            .padding(.bottom, 30)
//                            .frame(minWidth: 600, maxWidth: 800)
                        #if os(tvOS)
                            .frame(width: 800)
                        #endif
                        DownloadButton(viewModel: downloadModel)
                            .buttonStyle(TVButtonStyle(onFocus: onFocus))
                    }
//                    .background(Color.red)
                }
//                .background(Color.blue)
            }
            .padding(0)
            .frame(height: theme.currentEpisode.height)
//            #if os(tvOS)
//            .frame(maxWidth: .infinity)
            .padding([.leading, .trailing], theme.currentEpisode.padding)
//            #endif
//            .background(Color.gray)
        }
    }
}

struct EpisodesView_Previews: PreviewProvider {
    static var previews: some View {
        let show = Show.dummy()
        EpisodesView(show: show, episodes: show.episodes, currentSeason: 0, currentEpisode: show.episodes.first)
    }
}
