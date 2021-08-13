//
//  ShowView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 27.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import Kingfisher

struct ShowView: View {
    struct Theme {
        let fontSize: CGFloat = value(tvOS: 28, macOS: 18)
    }
    static let theme = Theme()
    
    var show: Show
    
    var body: some View {
        VStack {
            KFImage(URL(string: show.smallCoverImage ?? ""))
                .resizable()
                .placeholder {
                    Image("Episode Placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .shadow(radius: 5)
//                .padding(.bottom, 5)
            Text(show.title)
                .font(.system(size: ShowView.theme.fontSize, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .shadow(color: .init(white: 0, opacity: 0.6), radius: 2, x: 0, y: 1)
                .padding(0)
                .zIndex(10)
//                .frame(height: 80)
        }
    }
}

struct ShowView_Previews: PreviewProvider {
    static var previews: some View {
        ShowView(show: Show.dummy())
            .background(Color.red)
            .frame(width: 250, height: 460, alignment: .center)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
