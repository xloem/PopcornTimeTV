//
//  PlayTorrentEpisode.swift
//  PopcornTime
//
//  Created by Alexandru Tudose on 15.01.2022.
//  Copyright © 2022 PopcornTime. All rights reserved.
//

import Foundation
import PopcornKit

struct PlayTorrentEpisode: Identifiable, Equatable {
    var id: String  { torrent.id }
    var torrent: Torrent
    var episode: Episode
}

struct NextEpisode {
    var episode: Episode
    var show: Show
    
    init?(media: Media) {
        switch media {
        case is Movie:
            return nil
        case is Show:
            return nil
        case let episode as Episode:
            if let show = episode.show {
                self.episode = episode
                self.show = show
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    init(episode: Episode, show: Show) {
        self.episode = episode
        self.show = show
    }
    
    func next() -> NextEpisode? {
        var episodesLeftInShow = [Episode]()
        for season in show.seasonNumbers where season >= episode.season {
            episodesLeftInShow += show.episodes.filter({$0.season == season}).sorted(by: {$0.episode < $1.episode})
        }
        
        if let index = episodesLeftInShow.firstIndex(where: { $0.episode == episode.episode && $0.season == episode.season }) {
            episodesLeftInShow.removeFirst(index + 1)
        }
        
        let nextEpisode = !episodesLeftInShow.isEmpty ? episodesLeftInShow.removeFirst() : nil
        return nextEpisode.flatMap({ NextEpisode(episode: $0, show: show) })
    }
}
