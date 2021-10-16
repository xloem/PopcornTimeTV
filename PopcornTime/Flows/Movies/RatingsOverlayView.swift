//
//  RatingsOverlayView.swift
//  PopcornTime
//
//  Created by Alexandru Tudose on 25.09.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct RatingsOverlayView: View {
    let theme = Theme()
    var ratings: Ratings?
    
    var body: some View {
        if let ratings = ratings, ratings.hasValue {
            HStack(spacing: 15) {
                if let metascore = ratings.metascore {
                    HStack(spacing: 4) {
                        Image("metacritic")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: theme.imageHeight)
                        Text(metascore)
                    }
                }
                if let imdb = ratings.imdbRating {
                    HStack(spacing: 4) {
                        Image("imdb")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: theme.imageHeight)
                        Text(imdb)
                    }
                }
                if let rotten = ratings.rottenTomatoes, (ratings.imdbRating == nil || ratings.metascore == nil) {
                    HStack(spacing: 4) {
                        Image("rotten-tomatoes")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: theme.imageHeight)
                        Text(rotten)
                    }
                }
            }
            .font(.caption)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.verticalPadding)
            .background(.regularMaterial)
        }
    }
    
    struct Theme {
        let imageHeight: CGFloat = value(tvOS: 26, macOS: 20)
        let verticalPadding: CGFloat = value(tvOS: 10, macOS: 5)
    }
}

struct RatingsOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RatingsOverlayView(ratings: Ratings(awards: nil, imdbRating: "23", metascore: "42", rottenTomatoes: "34"))
            RatingsOverlayView(ratings: Ratings(awards: nil, imdbRating: nil, metascore: "42", rottenTomatoes: "34"))
            RatingsOverlayView(ratings: Ratings(awards: nil, imdbRating: nil, metascore: nil, rottenTomatoes: "34"))
        }
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
