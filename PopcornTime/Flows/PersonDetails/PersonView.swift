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
    struct Theme {
        let initalsTitleSize: CGFloat = value(tvOS: 100, macOS: 50)
        let nameSize: CGFloat = value(tvOS: 30, macOS: 16)
        let characterNameSize: CGFloat = value(tvOS: 26, macOS: 13)
    }
    let theme = Theme()
    
    var person: Person
    var radius: CGFloat = 220
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing:0) {
                ZStack() {
                    Circle()
                        .foregroundColor(Color(white: 0.8, opacity: 0.667))
                        .frame(width: radius, height: radius)
                    Text(person.initials)
                        .foregroundColor(Color.black)
                        .font(.system(size: theme.initalsTitleSize, weight: .regular))
                    if let image = person.mediumImage {
                        KFImage(URL(string: image))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: radius, height: radius)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                }
            }
            Text(person.name)
                .font(.system(size: theme.nameSize, weight: .medium))
                .padding(.top, 10)
            if let actor = person as? Actor {
                Text(actor.characterName.uppercased())
                    .font(.system(size: theme.characterNameSize, weight: .bold))
            } else if let crew = person as? Crew {
                Text(crew.job.uppercased())
                    .font(.system(size: theme.characterNameSize, weight: .bold))
            }
        }
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .shadow(color: .init(white: 0, opacity: 0.6), radius: 2, x: 0, y: 1)
    }
}

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        let actor1 = Actor(name: "Chuck Norris", imdbId: "23", tmdbId: 2, largeImage: nil)
        
        let actor2 = Actor(name: "Chuck Norris", imdbId: "23", tmdbId: 2, largeImage: "https://image.tmdb.org/t/p/w780/cgoy7t5Ve075naBPcewZrc08qGw.jpg")
        let actor3 = Actor(name: "Chuck Norris", imdbId: "23", tmdbId: 2, largeImage: "https://image.tmdb.org/t/p/w780/cgoy7t5Ve075naBPcewZrc08qGw.jpg", characterName: "The kill")
        HStack {
            PersonView(person: actor1)
            .frame(width: 220, height: 321, alignment: .leading)
            
            PersonView(person: actor2)
            .frame(width: 220, height: 321, alignment: .leading)
            
            PersonView(person: actor3)
            .frame(width: 220, height: 321, alignment: .leading)
        }
            .previewLayout(.sizeThatFits)
    }
}
