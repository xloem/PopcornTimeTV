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
    var show: Show
    
    var body: some View {
        VStack {
            KFImage(URL(string: show.smallCoverImage ?? ""))
                .resizable()
                .placeholder {
                    Image("Movie Placeholder")
                }
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.bottom, 5)
            Text(show.title)
                .lineLimit(2)
                .frame(height: 80)
        }
    }
}

struct ShowView_Previews: PreviewProvider {
    static var previews: some View {
        ShowView(show: Show.dummy())
            .background(Color.red)
            .frame(width: 250, height: 460, alignment: .center)
    }
}
