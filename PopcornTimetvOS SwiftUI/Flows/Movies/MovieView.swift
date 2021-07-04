//
//  MovieView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import Kingfisher
import PopcornKit

struct MovieView: View {
    var movie: Movie
    var lineLimit = 1
    
    var body: some View {
        VStack {
            KFImage(URL(string: movie.smallCoverImage ?? ""))
                .resizable()
                .placeholder {
                    Image("Movie Placeholder")
                }
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .shadow(radius: 5)
//                .padding(.bottom, 5)
            Text(movie.title)
                .font(.system(size: 28, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(lineLimit)
                .shadow(color: .init(white: 0, opacity: 0.6), radius: 2, x: 0, y: 1)
                .padding(0)
                .zIndex(10)
//                .frame(height: 80)
        }
    }
}

struct MovieView_Previews: PreviewProvider {
    static var previews: some View {
        MovieView(movie: Movie.dummy())
            .background(Color.red)
            .frame(width: 250, height: 460, alignment: .center)
    }
}
