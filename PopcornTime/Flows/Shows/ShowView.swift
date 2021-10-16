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
    let theme = Theme()
    
    var show: Show
    var ratingsLoader: ShowRatingsLoader?
    @Environment(\.isFocused) var focused: Bool
    #if os(iOS)
    @Environment(\.isButtonPress) var isButtonPress: Bool
    #endif
    @State var longPress: Bool = false
    
    var body: some View {
        VStack {
            KFImage(URL(string: show.smallCoverImage ?? ""))
                .resizable()
                .loadImmediately()
                .placeholder {
                    Image("Episode Placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .aspectRatio(contentMode: .fit)
                .overlay(alignment: theme.ratingAlignment) {
                    if focused || longPress {
                        RatingsOverlayView(ratings: show.ratings)
                            .transition(.move(edge: theme.ratingEdge))
                    }
                }
                .cornerRadius(10)
                .shadow(radius: 5)
//                .padding(.bottom, 5)
            Text(show.title)
                .font(.system(size: theme.fontSize, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .shadow(color: .init(white: 0, opacity: 0.6), radius: 2, x: 0, y: 1)
                .padding(0)
                .zIndex(10)
//                .frame(height: 80)
        }
        .drawingGroup() // increase scroll perfomance
        #if os(iOS)
        .onChange(of: isButtonPress, perform: { newValue in
            withAnimation(Animation.easeOut.delay(newValue ? 0.5 : 0)) {
                self.longPress = newValue
            }
        })
        #endif
        .onAppear {
            ratingsLoader?.loadRatingIfMissing(show: show)
        }
    }
    
    struct Theme {
        let fontSize: CGFloat = value(tvOS: 28, macOS: 16)
        let ratingEdge: Edge = value(tvOS: .bottom, macOS: .top)
        let ratingAlignment: Alignment = value(tvOS: .bottom, macOS: .top)
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
