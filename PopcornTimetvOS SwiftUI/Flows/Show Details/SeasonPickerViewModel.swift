//
//  SeasonPickerViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 05.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

class SeasonPickerViewModel: ObservableObject {
    struct Season: Hashable {
        var number: Int
        var image: String?
    }
    
    var show: Show
    var seasons: [Season] = []
    @Published var isLoading = false
    var didLoad = false
    
    init(show: Show) {
        self.show = show
        self.seasons = show.seasonNumbers.compactMap{ .init(number: $0, image: nil) }
    }
    
    func load() {
        guard !isLoading && !didLoad else {
            return
        }
        
        isLoading = true
        let group = DispatchGroup()
        
        for (index, season) in show.seasonNumbers.enumerated() {
            group.enter()
            TMDBManager.shared.getSeasonPoster(ofShowWithImdbId: show.id, orTMDBId: show.tmdbId, season: season) { (tmdb, image, _) in
                if let tmdb = tmdb {
                    self.show.tmdbId = tmdb
                }
                self.seasons[index] = Season(number: season, image: image ?? self.show.largeCoverImage)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            self.didLoad = true
        }
    }
}
