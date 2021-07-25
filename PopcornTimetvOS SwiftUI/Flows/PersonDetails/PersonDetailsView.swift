//
//  PersonDetailView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 04.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct PersonDetailsView: View {
    @StateObject var viewModel: PersonDetailsViewModel
    
    var body: some View {
        ZStack {
            ScrollView {
                Text(viewModel.person.name)
                    .font(.title)
                if viewModel.movies.count > 0 {
                    movieSection
                }
                if viewModel.shows.count > 0 {
                    showSection
                }
            }
            .padding(.leading, 90)
            .padding(.horizontal)
            .ignoresSafeArea(edges: [.leading, .trailing])
            .onAppear {
                viewModel.load()
            }
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
    
    @ViewBuilder
    var movieSection: some View {
        VStack(alignment: .leading) {
            Text("Movies".localized)
                .font(.callout)
                .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
                .padding(.top, 14)
            ScrollView(.horizontal) {
                HStack(spacing: 40) {
                    ForEach(viewModel.movies, id: \.self) { movie in
                        NavigationLink(
                            destination: MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie)),
                            label: {
                                MovieView(movie: movie)
                                    .frame(width: 240)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
//                            .padding([.leading, .trailing], 10)
                    }
                    .padding(20) // allow zoom
                }.padding(.all, 0)
            }
        }
    }
    
    @ViewBuilder
    var showSection: some View {
        VStack(alignment: .leading) {
            Text("Shows".localized)
                .font(.callout)
                .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
                .padding(.top, 14)
            ScrollView(.horizontal) {
                HStack(spacing: 40) {
                    ForEach(viewModel.shows, id: \.self) { show in
                        NavigationLink(
                            destination: ShowDetailsView(viewModel: ShowDetailsViewModel(show: show)),
                            label: {
                                ShowView(show: show)
                                    .frame(width: 240)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
//                            .padding([.leading, .trailing], 10)
                    }
                    .padding(20) // allow zoom
                }.padding(.all, 0)
            }
        }
    }
}

struct PersonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let actor = Actor(name: "Chuck Norris", imdbId: "23", tmdbId: 2, largeImage: nil)
        let viewModel = PersonDetailsViewModel(person: actor)
        viewModel.movies = Movie.dummiesFromJSON()
        viewModel.shows = Show.dummiesFromJSON()
        return VStack {
            PersonDetailsView(viewModel: viewModel)
        }
    }
}
