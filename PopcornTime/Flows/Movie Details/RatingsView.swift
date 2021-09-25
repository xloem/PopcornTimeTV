//
//  RatingsView.swift
//  PopcornTime
//
//  Created by Alexandru Tudose on 25.09.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct RatingsView: View {
    let theme = Theme()
    var viewModel: RatingsViewModel
    @Environment(\.openURL) var openURL
    
    var body: some View {
        ratings()
    }
    
    @ViewBuilder
    func ratings() -> some View {
        if let ratings = viewModel.ratings {
            HStack(spacing: 25) {
                if let imdb = ratings.imdbRating {
                    ratingItem(image: "imdb", value: imdb)
                    #if os(iOS) || os(macOS)
                        .onTapGesture {
                            openURL(viewModel.media.imdbUrl)
                        }
                    #endif
                } else {
                    
                }
                if let metascore = ratings.metascore {
                    ratingItem(image: "metacritic", value: metascore)
                    #if os(iOS) || os(macOS)
                        .onTapGesture {
                            openURL(viewModel.metacriticFindUrl)
                        }
                    #endif
                }
                if let rotten = ratings.rottenTomatoes {
                    ratingItem(image: "rotten-tomatoes", value: rotten)
                    #if os(iOS) || os(macOS)
                        .onTapGesture {
                            openURL(viewModel.rottentomatoesUrl)
                        }
                    #endif
                }
            }
            .font(.caption)
            .lineLimit(1)
        }
    }
    
    func ratingItem(image: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: theme.ratingHeight)
            Text(value)
            #if os(macOS)
                .font(.title2)
            #endif
        }
    }
}
extension RatingsView {
    struct Theme {
        let ratingHeight: CGFloat = value(tvOS: 32, macOS: 24)
    }
}

struct RatingsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            RatingsView(viewModel: RatingsViewModel(media: Movie.dummy(), ratings: Ratings(awards: "", imdbRating: "23", metascore: "42", rottenTomatoes: "")))
            
            RatingsView(viewModel: RatingsViewModel(media: Movie.dummy(), ratings: Ratings(awards: "", imdbRating: "23", metascore: "42", rottenTomatoes: nil)))
            
            RatingsView(viewModel: RatingsViewModel(media: Movie.dummy(), ratings: Ratings(awards: "", imdbRating: "23", metascore: nil, rottenTomatoes: nil)))
            
            RatingsView(viewModel: RatingsViewModel(media: Movie.dummy(), ratings: Ratings(awards: "", imdbRating: "", metascore: nil, rottenTomatoes: nil)))
            
            RatingsView(viewModel: RatingsViewModel(media: Movie.dummy(), ratings: Ratings(awards: "", imdbRating: nil, metascore: nil, rottenTomatoes: nil)))
        }
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
