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
    
    func loadRatingIfMissing(movie: Movie)
}

extension MovieRatingsLoader {
    func loadRatingIfMissing(movie: Movie) {
        guard movie.ratings == nil else {
            return
        }
        
        OMDbManager.shared.loadCachedInfo(imdbId: movie.id) { media, error in
            if let media = media, let index = self.movies.firstIndex(where: {$0.id == movie.id}) {
                self.movies[index].ratings = media.transform()
            }
        }
    }
}

//protocol ShowRatingsLoader: AnyObject {
//    var shows: [Show] {get set}
//
//    func loadRatingIfMissing(show: Show)
//}
//
//extension ShowRatingsLoader {
//    func loadRatingIfMissing(show: Show) {
//        guard show.ratings == nil else {
//            return
//        }
//
//        OMDbManager.shared.loadCachedInfo(imdbId: show.id) { media, error in
//            if let media = media, let index = self.shows.firstIndex(where: {$0.id == show.id}) {
//                let ratings = Ratings(awards: media.awards, imdbRating: media.imdbRating, metascore: media.metascore)
//                var show = self.shows[index]
//                show.ratings = ratings
//                self.shows[index] = show
//            }
//        }
//    }
//}
