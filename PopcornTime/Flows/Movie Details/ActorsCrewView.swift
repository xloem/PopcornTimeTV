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
                HStack(alignment: .center, spacing: 90) {
                    Spacer(minLength: 90)
                    ForEach(0..<persons.count, id: \.self) { index in
                        NavigationLink(
                            destination: PersonDetailsView(viewModel: PersonDetailsViewModel(person: persons[index])),
                            label: {
                                PersonView(person: persons[index])
                                    .frame(width: 220)
//                                    .background(Color.blue)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
                    }
//                    Spacer()
                }
                .padding() // on focus zoom will not be clipped
//                .frame(height: 321)
//                .background(Color.blue)
                Spacer()
            }
            .frame(height: 321)
//            .background(Color.gray)
        }
//        .background(Color.red)
        .padding(0)
    }
}

struct ActorsCrewView_Previews: PreviewProvider {
    static var previews: some View {
        let show = Show.dummy()
        ActorsCrewView(persons: show.actors + show.crew)
    }
}
