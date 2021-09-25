//
//  RatingsViewModel.swift
//  PopcornTime
//
//  Created by Alexandru Tudose on 25.09.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import PopcornKit

class RatingsViewModel {
    var media: Media
    var ratings: Ratings?
    
    init(media: Media, ratings: Ratings?) {
        self.media = media
        
        #if os(tvOS)
        self.ratings = ratings
        #else
        if var ratings = ratings, ratings.hasValue {
            if ratings.imdbRating == nil {
                ratings.imdbRating = "" // for opening website
            }
            self.ratings = ratings
        } else {
            // show empty imdb when no ratings, for opening website
            self.ratings = Ratings(awards: nil, imdbRating: "", metascore: nil, rottenTomatoes: nil)
        }
        #endif
    }
    
    var metacriticFindUrl: URL {
        switch media {
        case let movie as Movie:
            return movie.metacriticFindUrl
        case let show as Show:
            return show.metacriticUrl
        default:
            return URL(string: "")!
        }
    }
    
    var rottentomatoesUrl: URL {
        switch media {
        case let movie as Movie:
            return movie.rottentomatoesUrl
        case let show as Show:
            return show.rottentomatoesUrl
        default:
            return URL(string: "")!
        }
    }
}
