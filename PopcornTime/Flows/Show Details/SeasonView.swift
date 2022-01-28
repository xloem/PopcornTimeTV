//
//  SeasonView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 05.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import Kingfisher

struct SeasonView: View {
    var season: SeasonPickerViewModel.Season
    
    var body: some View {
        VStack {
            KFImage(URL(string: season.image ?? ""))
                .resizable()
                .placeholder {
                    Image("Show Placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.bottom, 5)
            Text("Season".localized + " \(season.number)")
                .lineLimit(1)
        }
        .frame(width: 300, height: 550)
    }
}

struct SeasonView_Previews: PreviewProvider {
    static var previews: some View {
        SeasonView(season: .init(number: 1, image: nil))
    }
}
