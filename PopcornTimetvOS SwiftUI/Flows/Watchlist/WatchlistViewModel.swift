//
//  WatchlistViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 05.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

class WatchlistViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var shows: [Show] = []
    
    init() {
        
    }
    
    func load() {
        self.movies = WatchlistManager<Movie>.movie.getWatchlist()//.sorted(by: {$0.title < $1.title})
        self.shows = WatchlistManager<Show>.show.getWatchlist()//.sorted(by: {$0.title < $1.title})
    }
    
}
