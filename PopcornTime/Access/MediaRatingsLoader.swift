//
//  MediaRatingsLoader.swift
//  PopcornTime
//
//  Created by Alexandru Tudose on 07.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import PopcornKit


protocol MovieRatingsLoader: AnyObject {
    var movies: [Movie] {get set}
    
    func loadRatingIfMissing(movie: Movie) async
}


extension MovieRatingsLoader {
    
    @MainActor
    func loadRatingIfMissing(movie: Movie) async {
        guard movie.ratings == nil else {
            return
        }
        
        let info = try? await OMDbApi.shared.loadCachedInfo(imdbId: movie.id)
        if let info = info, let index = self.movies.firstIndex(where: {$0.id == movie.id}) {
            self.movies[index].ratings = info.transform()
        }
    }
}

protocol ShowRatingsLoader: AnyObject {
    var shows: [Show] {get set}

    func loadRatingIfMissing(show: Show) async
}

extension ShowRatingsLoader {
    
    @MainActor
    func loadRatingIfMissing(show: Show) async {
        guard show.ratings == nil else {
            return
        }

        let info = try? await OMDbApi.shared.loadCachedInfo(imdbId: show.id)
        if let info = info, let index = self.shows.firstIndex(where: {$0.id == show.id}) {
            self.shows[index].ratings = info.transform()
        }
    }
}
