//
//  Actors&CrewView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 05.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct ActorsCrewView: View {
    struct Theme {
        let section: (height: CGFloat, cellWidth: CGFloat, spacing: CGFloat) = (height: value(tvOS: 321, macOS: 218),
                                                                                        cellWidth: value(tvOS: 220, macOS: 150),
                                                                                        spacing: value(tvOS: 90, macOS: 30))
    }
    let theme = Theme()
    
    var persons: [Person]
    
    var body: some View {
        return VStack(alignment: .leading) {
            Text("Cast & Crew".localized)
                .font(.callout)
                .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
                .padding(.leading, theme.section.spacing)
                .padding(.top, 14)
            ScrollView(.horizontal, showsIndicators: false) {
                Spacer()
                     .frame(height: 30) // on focus zoom will not be clipped
                LazyHStack(alignment: .center, spacing: theme.section.spacing) {
                    Spacer(minLength: theme.section.spacing)
                    ForEach(0..<persons.count, id: \.self) { index in
                        personView(person: persons[index])
                    }
                }
                Spacer()
            }
            .frame(height: theme.section.height)
        }
        .padding(0)
    }
    
    @ViewBuilder
    func personView(person: Person) -> some View {
        NavigationLink(
            destination: PersonDetailsView(viewModel: PersonDetailsViewModel(person: person)),
            label: {
                PersonView(person: person, radius: theme.section.cellWidth)
                    .frame(width: theme.section.cellWidth)
            })
            .buttonStyle(PlainNavigationLinkButtonStyle())
    }
}

struct ActorsCrewView_Previews: PreviewProvider {
    static var previews: some View {
        let show = Show.dummy()
        ActorsCrewView(persons: show.actors + show.crew)
            .previewLayout(.sizeThatFits)
    }
}
