//
//  InfoView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import Kingfisher

struct InfoView: View {
    let media: Media?
    
    var body: some View {
        if let media = media {
            HStack(spacing: 0) {
                KFImage(URL(string: media.smallCoverImage ?? ""))
                    .resizable()
                    .placeholder {
                        Image("Movie Placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.bottom, 5)
                    .padding(.trailing, 40)
                    .frame(maxWidth: 400)
                VStack(alignment: .leading, spacing: 0) {
                    Text(media.title)
                        .lineLimit(1)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.init(white: 1.0, opacity: 0.5))
                        .frame(height: 39)
                        .padding(.bottom, 10)
                    infoText
                        .lineLimit(1)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.init(white: 1.0, opacity: 0.5))
                        .frame(height: 39)
                        .padding(.bottom, 4)
                    Text(media.summary)
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(.init(white: 1.0, opacity: 0.5))
                        .frame(maxHeight: 140)
                        .padding(.bottom, 4)
//                    Spacer()
                }
            }
            .padding(0)
            .padding([.leading, .trailing], 80)
        } else {
            Text("No info available.".localized)
                .font(.system(size: 35, weight: .medium))
                .foregroundColor(.init(white: 1.0, opacity: 0.5))
        }
    }
    
//    @ViewBuilder
    var infoText: some View {
        if let movie = media as? Movie {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .short
            formatter.allowedUnits = [.hour, .minute]
            let runtime = formatter.string(from: TimeInterval(movie.runtime) * 60)
            let year = movie.year
            
            let items = [Text([runtime, year].compactMap({$0}).joined(separator: "\t"))]
                + ([movie.certification, "HD", "CC"]).map {
                    Text(Image($0).renderingMode(.template))
                }
            return HStack(alignment: .center, spacing: 25) {
                ForEach(0..<items.count) { item in
                    items[item]
                }
            }
        } else {
            return HStack(alignment: .center, spacing: 25) {
                ForEach(0..<[""].count) { item in
                    Text("")
                }
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InfoView(media: Movie.dummy())
            InfoView(media: nil)
        }.previewLayout(.sizeThatFits)
    }
}
