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
        ScrollView {
            LazyVGrid(columns: columns, spacing: 60) {
                ForEach(viewModel.movies, id: \.self) { movie in
                    NavigationLink(
                        destination: DetailView(viewModel: DetailViewModel(movie: movie)),
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
        }
        .padding(.horizontal)
        .onAppear {
            viewModel.loadMovies()
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
