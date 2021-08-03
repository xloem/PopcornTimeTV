//
//  ShowDetailsViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 04.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import PopcornKit
import SwiftUI

class ShowDetailsViewModel: ObservableObject {
    @Published var show: Show
    var error: Error?
    @Published var currentSeason = -1
    
    @Published var isLoading = false
    @Published var didLoad = false
    
    init(show: Show) {
        self.show = show
    }
    
    var backgroundUrl: URL {
        return URL(string: show.largeBackgroundImage ?? "")!
    }
    
    func load() {
        guard !isLoading, !didLoad else {
            return
        }
        
        isLoading = true
        PopcornKit.getShowInfo(show.id) { (show, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            guard let show = show else {
                self.isLoading = false
                return
            }
            
            self.show = show
            
            guard let season = show.latestUnwatchedEpisode()?.season ?? show.seasonNumbers.first else {
                let error = NSError(domain: "com.popcorntimetv.popcorntime.error", code: -243, userInfo:
                                        [NSLocalizedDescriptionKey: "There are no seasons available for the selected show. Please try again later.".localized])
                self.error = error
                self.isLoading = false
                return
            }
            self.currentSeason = season
            
            let group = DispatchGroup()
                
            group.enter()
            TraktManager.shared.getRelated(self.show) {arg1, _ in
                self.show.related = arg1
                group.leave()
            }
            
            group.enter()
            TraktManager.shared.getPeople(forMediaOfType: .shows, id: self.show.id) {arg1,arg2,_ in
                self.show.actors = arg1
                self.show.crew = arg2
                group.leave()
            }
            
            group.enter()
            self.loadEpisodeMetadata(for: show) { episodes in
                self.show.episodes = episodes
                self.isLoading = false
                group.leave()
            }
            
            group.notify(queue: .main) {
                self.didLoad = true
            }
        }
    }
    
    func loadEpisodeMetadata(for show: Show, completion: @escaping ([Episode]) -> Void) {
        let group = DispatchGroup()
        
        var episodes = [Episode]()
        
        for var episode in show.episodes {
            group.enter()
            TMDBManager.shared.getEpisodeScreenshots(forShowWithImdbId: show.id, orTMDBId: show.tmdbId, season: episode.season, episode: episode.episode, completion: { (tmdbId, image, error) in
                if let image = image { episode.largeBackgroundImage = image }
                if let tmdbId = tmdbId { episode.show?.tmdbId = tmdbId }
                episodes.append(episode)
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            episodes.sort(by: { $0.episode < $1.episode })
            completion(episodes)
        }
    }
    
    func playSongTheme() {
        if let tvdbId = Int(show.tvdbId) {
            ThemeSongManager.shared.playShowTheme(tvdbId)
        }
    }
    
    func stopTheme() {
        ThemeSongManager.shared.stopTheme()
    }
    
    func seasonEpisodes() -> [Episode] {
        return show.episodes.filter({$0.season == currentSeason}).sorted(by: {$0.episode < $1.episode})
    }
}
