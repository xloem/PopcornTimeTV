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
    var persons: [Person]
    
    var body: some View {
        return VStack(alignment: .leading) {
            Text("Cast & Crew".localized)
                .font(.callout)
                .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
                .padding(.leading, 90)
                .padding(.top, 14)
            ScrollView(.horizontal, showsIndicators: false) {
                Spacer()
                     .frame(height: 30) // on focus zoom will not be clipped
                LazyHStack(alignment: .center, spacing: 90) {
                    Spacer(minLength: 90)
                    ForEach(0..<persons.count, id: \.self) { index in
                        personView(person: persons[index])
                    }
                }
                Spacer()
            }
            .frame(height: 321)
        }
        .padding(0)
    }
    
    @ViewBuilder
    func personView(person: Person) -> some View {
        NavigationLink(
            destination: PersonDetailsView(viewModel: PersonDetailsViewModel(person: person)),
            label: {
                PersonView(person: person)
                    .frame(width: 220)
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
