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
    @Published var currentSeason = -1 {
        didSet {
            latestUnwatchedEpisode = show.latestUnwatchedEpisode(from: self.seasonEpisodes())
        }
    }
    
    @Published var isLoading = false
    @Published var didLoad = false
    var latestUnwatchedEpisode: Episode?
    
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
        
        if show.ratings == nil {
            OMDbManager.shared.loadCachedInfo(imdbId: show.id) { info, error in
                if let info = info {
                    self.show.ratings = info.transform()
                }
            }
        }
        
        isLoading = true
        PopcornKit.getShowInfo(show.id) { (show, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            guard var show = show else {
                self.isLoading = false
                return
            }
            
            show.largeBackgroundImage = self.show.largeBackgroundImage ?? show.largeBackgroundImage //keep last background
            show.ratings = self.show.ratings
            self.show = show
            
            guard let season = show.latestUnwatchedEpisode()?.season ?? show.seasonNumbers.first else {
                let error = NSError(domain: "com.popcorntimetv.popcorntime.error", code: -243, userInfo:
                                        [NSLocalizedDescriptionKey: "There are no seasons available for the selected show. Please try again later.".localized])
                self.error = error
                self.isLoading = false
                return
            }
            self.currentSeason = season
            self.isLoading = false
            self.didLoad = true
            
            let group = DispatchGroup()
                
            group.enter()
            TraktManager.shared.getRelated(self.show) { related, _ in
                self.show.related = related
                group.leave()
            }
            
            group.enter()
            TraktManager.shared.getPeople(forMediaOfType: .shows, id: self.show.id) { actors, crew, _ in
                self.show.actors = actors
                self.show.crew = crew
                group.leave()
            }
            
//            group.enter()
//            self.loadEpisodeMetadata(for: show) { episodes in
//                self.show.episodes = episodes
//                self.isLoading = false
//                group.leave()
//            }
//            
//            group.notify(queue: .main) {
//                self.didLoad = true
//            }
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
    
    func nextEpisodeToWatch() -> Episode? {
        return latestUnwatchedEpisode ?? seasonEpisodes().first
    }
    
    func loadImageIfMissing(episode: Episode) {
        guard episode.smallBackgroundImage == nil else { return }
        
        TMDBManager.shared.getEpisodeScreenshots(forShowWithImdbId: show.id, orTMDBId: show.tmdbId, season: episode.season, episode: episode.episode, completion: { (tmdbId, image, error) in
//            print("episode image", image ?? "None")
            var episode = episode
            episode.largeBackgroundImage = image ?? ""
            if let tmdbId = tmdbId { episode.show?.tmdbId = tmdbId }
            
            if let index = self.show.episodes.firstIndex(where: {$0.id == episode.id }) {
                self.show.episodes[index] = episode
            }
        })
    }
}
