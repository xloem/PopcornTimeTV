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
    @State var showTorrent: PlayTorrent?
    
    struct PlayTorrent: Identifiable, Equatable {
        var id: String  { torrent.id }
        var torrent: Torrent
        var episode: Episode
    }
    
    var onFocus: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading) {
            titleView
            episodesCountView
            ScrollView(.horizontal) {
                LazyHStack(spacing: theme.episodeSpacing) {
                    ForEach(episodes, id: \.self) { episode in
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
            TorrentPlayerView(torrent: item.torrent, media: item.episode)
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
        SelectTorrentQualityButton(media: episode, action: { torrent in
            self.currentEpisode = episode
            showTorrent = PlayTorrent(torrent: torrent, episode: episode)
        }, label: {
            EpisodeView(episode: episode)
        })
        .frame(width: theme.episodeWidth, height: theme.episodeHeight)
        .buttonStyle(TVButtonStyle(onFocus: {
            currentEpisode = episode
            onFocus()
        }, onPressed: {
            currentEpisode = episode
        }, isSelected: episode.id == currentEpisode?.id))
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
            .padding(.leading, theme.leading)
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
                        #if !os(tvOS)
                            .padding(.horizontal, 30)
                        #endif
                    HStack {
                        Text(episode.summary)
                            .multilineTextAlignment(.leading)
//                            .lineLimit(6)
                            .padding(.bottom, 30)
//                            .frame(minWidth: 600, maxWidth: 800)
                        #if os(tvOS)
                            .frame(width: 800)
                        #else
                            .padding(.horizontal, 30)
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

extension EpisodesView {
    struct Theme {
        let episodeWidth: CGFloat = value(tvOS: 310, macOS: 217)
        let episodeHeight: CGFloat = value(tvOS: 215, macOS: 150)
        let episodeSpacing: CGFloat = value(tvOS: 40, macOS: 20)
        let currentEpisode: (padding: CGFloat, height: CGFloat)
            = (padding: value(tvOS: 250, macOS: 80),
               height: value(tvOS: 350, macOS: 250))
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
            EpisodesView(show: show, episodes: show.episodes, currentSeason: 0, currentEpisode: episode, downloadModel: downloadModel)
                .environmentObject(showDetails)
//                .frame(maxHeight: 500)
            
            EpisodesView(show: show, episodes: show.episodes, currentSeason: 0, currentEpisode: episode)
                .environmentObject(showDetails)
//                .frame(maxHeight: 300)
        }
            .preferredColorScheme(.dark)
//            .previewLayout(.sizeThatFits)
            .background(.gray)
    }
}
