//
//  StarRatingView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 07.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct StarRatingView: View {
    var count = 5
    let rating: Double

    var body: some View {
        let intRating: Int = Int(floor(rating))
        HStack(spacing: 5) {
            ForEach(0..<count) { index in
                switch index {
                case ..<intRating:
                    Image("Star Full")
                case intRating:
                    Image("Star Empty")
                        .overlay(clippedImage)
                case intRating...:
                    Image("Star Empty")
                default:
                    Image("Star Empty")
                }
            }
        }
    }
    
    @ViewBuilder
    var clippedImage: some View {
        let percentage = CGFloat(rating - floor(rating))
        Image("Star Full")
            .clipShape(MaskShape(percentage: percentage))
    }
    
    struct MaskShape : Shape {
        var percentage: CGFloat
        
        func path(in rect: CGRect) -> Path {
            let rect = rect.inset(by: .init(top: 0, left: 0, bottom: 0, right: rect.width - rect.width * percentage))
            
            return Rectangle().path(in: rect)
        }
    }
}

struct StarRatingView_Previews: PreviewProvider {
    static var previews: some View {
        StarRatingView(rating: 2.4)
            .previewLayout(.sizeThatFits)
    }
}
