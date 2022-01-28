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
    @State var showTorrent: PlayTorrentEpisode?
    
    var onFocus: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading) {
            titleView
            episodesCountView
            ScrollView(.horizontal) {
                LazyHStack(spacing: theme.episodeSpacing) {
                    ForEach(episodes, id: \.episode) { episode in
                        episodeView(episode: episode)
                    }
                }
                .padding([.top, .bottom], 20) // allow zooming to be visible
                .padding([.leading, .trailing], theme.leading)
            }
            currentEpisodeView
            #if os(tvOS)
                .focusSection()
            #endif
        }
        .fullScreenContent(item: $showTorrent, title: show.title, content: { item in
            TorrentPlayerView(torrent: item.torrent,
                              media: item.episode,
                              nextEpisode: NextEpisode(episode: item.episode, show: show).next())
        })
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
    func episodeView(episode: Episode) -> some View {
        let isSelected = episode.id == currentEpisode?.id && episode.episode == currentEpisode?.episode
        SelectTorrentQualityButton(media: episode, action: { torrent in
            self.currentEpisode = episode
            showTorrent = PlayTorrentEpisode(torrent: torrent, episode: episode)
        }, label: {
            EpisodeView(episode: episode, isSelected: isSelected)
        })
        .frame(width: theme.episodeWidth, height: theme.episodeHeight)
        .buttonStyle(TVButtonStyle(onFocus: {
            currentEpisode = episode
            onFocus()
        }, onPressed: {
            currentEpisode = episode
        }, isSelected: isSelected))
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
            .foregroundColor(.appSecondary)
            .padding(.leading, theme.leading)
            .padding(.top, 14)
    }
    
    @ViewBuilder
    var currentEpisodeView: some View {
        if let episode = currentEpisode {
            HStack {
                VStack(alignment: .leading, spacing: 20) {
                    Text("\(episode.episode). " + episode.title)
                        .font(.headline)
                    HStack {
                        Text(episode.summary)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: theme.currentEpisode.trailing)
                    }
                    if episode == currentEpisode, let downloadModel = downloadModel {
                        DownloadButton(viewModel: downloadModel)
                            .buttonStyle(TVButtonStyle(onFocus: onFocus))
                    }
                }
                .padding([.leading], theme.currentEpisode.leading + 10)
                Spacer()
            }
            .frame(height: theme.currentEpisode.height)
        }
    }
}

extension EpisodesView {
    struct Theme {
        let episodeWidth: CGFloat = value(tvOS: 310, macOS: 217)
        let episodeHeight: CGFloat = value(tvOS: 215, macOS: 150)
        let episodeSpacing: CGFloat = value(tvOS: 40, macOS: 20)
        let currentEpisode: (leading: CGFloat, height: CGFloat, trailing: CGFloat)
            = (leading: value(tvOS: 90, macOS: 20),
               height: value(tvOS: 350, macOS: 250),
               trailing: value(tvOS: 500, macOS: 200))
        let leading: CGFloat = value(tvOS: 90, macOS: 50)
    }
}

struct EpisodesView_Previews: PreviewProvider {
    static var previews: some View {
        let show = Show.dummy()
        let episode = show.episodes.first!
        let downloadModel = DownloadButtonViewModel(media: show)
        let showDetails = ShowDetailsViewModel(show: show)
        
        Group {
            ScrollView {
                EpisodesView(show: show, episodes: show.episodes, currentSeason: 0, currentEpisode: episode, downloadModel: downloadModel)
                    .environmentObject(showDetails)
            }
            
            ScrollView {
                EpisodesView(show: show, episodes: show.episodes, currentSeason: 0, currentEpisode: episode)
                    .environmentObject(showDetails)
            }
        }
            .preferredColorScheme(.dark)
            .background(.gray)
    }
}
