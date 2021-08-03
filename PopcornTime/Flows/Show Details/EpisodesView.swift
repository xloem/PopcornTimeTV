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
    var show: Show
    var episodes: [Episode]
    var currentSeason: Int
    @State var currentEpisode: Episode?
    
    @State var preloadTorrentModel: PreloadTorrentViewModel?
    @State var playerModel: PlayerViewModel?
    
    @State var torrent: Torrent?
    
    @State var selection: Selection? = nil
    enum Selection: Int, Identifiable {
        case preload = 2
        case play = 3
        
        var id: Int { return rawValue }
    }
    var onFocus: () -> Void = {}
    
    var body: some View {
        return VStack(alignment: .leading) {
            navigationLinks
            titleView
            episodesCountView
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(episodes, id: \.self) { episode in
                        SelectTorrentQualityButton(media: episode, action: { torrent in
                            playTorrent(torrent, episode: episode)
                        }, label: {
                           EpisodeView(episode: episode)
                        }, onFocus: {
                            currentEpisode = episode
                            onFocus()
                        })
                        .frame(width: 310, height: 215)
                    }
                }
                .padding()
                .padding(.leading, 90)
            }
            currentEpisodeView
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
    var navigationLinks: some View {
        if let _ = torrent {
            switch selection {
            case .some(.preload):
                NavigationLink(
                    destination: PreloadTorrentView(viewModel: preloadTorrentModel!),
                    tag: Selection.preload,
                    selection: $selection) {
                        EmptyView()
                }
            case .some(.play):
                NavigationLink(
                    destination: PlayerView().environmentObject(playerModel!),
                    tag: Selection.play,
                    selection: $selection) {
                        EmptyView()
                    }
            case nil: EmptyView()
            }
        }
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
        if let episode = currentEpisode {
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
                            .frame(minWidth: 600, maxWidth: 800)
                        DownloadButton(viewModel: DownloadButtonViewModel(media: episode))
                            .buttonStyle(TVButtonStyle(onFocus: onFocus))
                    }
                }
            }
            .frame(height: 400)
            .padding([.leading, .trailing], 250)
        }
    }
    
    func playTorrent(_ torrent: Torrent, episode: Episode) {
        self.torrent = torrent
        self.preloadTorrentModel = PreloadTorrentViewModel(torrent: torrent, media: episode, onReadyToPlay: { playerModel in
            self.playerModel = playerModel
            selection = .play
        })
        selection = .preload
    }
}

struct EpisodesView_Previews: PreviewProvider {
    static var previews: some View {
        let show = Show.dummy()
        EpisodesView(show: show, episodes: show.episodes, currentSeason: 0, currentEpisode: show.episodes.first)
    }
}


struct FocusedEpisode: FocusedValueKey {
    typealias Value = Binding<Media>
}

extension FocusedValues {
    var episodeBinding: FocusedEpisode.Value? {
        get { self[FocusedEpisode.self] }
        set { self[FocusedEpisode.self] = newValue }
    }
}
