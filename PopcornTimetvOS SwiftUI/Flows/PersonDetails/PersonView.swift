//
//  PersonView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import Kingfisher

struct PersonView: View {
    var person: Person
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing:0) {
                ZStack() {
                    Circle()
                        .foregroundColor(Color(white: 0.8, opacity: 0.667))
                    Text(person.initials)
                        .foregroundColor(Color.black)
                        .font(.system(size: 100, weight: .regular))
                    if let image = person.mediumImage {
                        KFImage(URL(string: image))
                            .resizable()
                            .placeholder {
                                Image("Movie Placeholder")
                            }
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
            Text(person.name)
                .font(.system(size: 30, weight: .medium))
            if let actor = person as? Actor {
                Text(actor.characterName.uppercased())
                    .font(.system(size: 26, weight: .bold))
            } else if let crew = person as? Crew {
                Text(crew.job.uppercased())
                    .font(.system(size: 26, weight: .bold))
            }
        }
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .shadow(color: .init(white: 0, opacity: 0.6), radius: 2, x: 0, y: 1)
    }
}

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        var actor = Actor(name: "Chuck Norris", imdbId: "23", tmdbId: 2, largeImage: nil)
        return PersonView(person: actor)
            .frame(width: 220, height: 321, alignment: .leading)
    }
}
