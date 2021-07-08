//
//  MoviesView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct MoviesView: View {
    @EnvironmentObject var viewModel: MoviesViewModel
    let columns = [
        GridItem(.adaptive(minimum: 240))
//        GridItem(.fixed(250), spacing: 80),
//        GridItem(.fixed(250), spacing: 80),
//        GridItem(.flexible(), spacing: 80)
    ]
    
    var body: some View {
        ZStack(alignment: .leading) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 60) {
                    ForEach(viewModel.movies, id: \.self) { movie in
                        NavigationLink(
                            destination: MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie)),
                            label: {
                                MovieView(movie: movie)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
                            .padding([.leading, .trailing], 10)
                    }
                    if (!viewModel.movies.isEmpty) {
                        loadingView
                    }
                }.padding(.all, 0)
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    ProgressView()
                }
            }
            .padding(.horizontal)
            .onAppear {
                viewModel.loadMovies()
            }
            LeftSidePanelView(currentSort: $viewModel.currentFilter, currentGenre: $viewModel.currentGenre)
                .padding(.leading, -50)
        }
    }
    
    @ViewBuilder
    var loadingView: some View {
        Text("")
            .onAppear {
                viewModel.loadMovies()
            }
        if viewModel.isLoading {
            ProgressView()
        }
    }
}

struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MoviesViewModel()
        model.movies = Movie.dummiesFromJSON()
        return MoviesView().environmentObject(model)
    }
}
