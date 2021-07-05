//
//  RatingView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 05.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import FloatRatingView
import SwiftUI

struct RatingView: UIViewRepresentable {
    var rating: Double
    
    func makeUIView(context: Context) -> FloatRatingView {
        let ratingView = FloatRatingView()
        ratingView.type = .floatRatings
        ratingView.emptyImage = UIImage(named: "Star Empty")
        ratingView.fullImage = UIImage(named: "Star Full")
        ratingView.minRating = 0
        ratingView.maxRating = 5
        ratingView.editable = false
        ratingView.minImageSize = CGSize(width: 33, height: 33)
        return ratingView
    }
    
    func updateUIView(_ uiView: FloatRatingView, context: Context) {
        uiView.rating = rating / 20
    }
    
    typealias UIViewType = FloatRatingView
}
