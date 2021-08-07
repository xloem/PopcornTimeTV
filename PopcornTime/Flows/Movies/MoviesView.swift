//
//  MoviesView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

//#if os(tvOS)
//let isTVOS = true
//let isMacOS = false
//#elseif os(macOS)
//let isTVOS = false
//let isMacOS = true
//#endif
func value<T>(tvOS: T, macOS: T) -> T {
    #if os(tvOS)
        return tvOS
    #elseif os(macOS)
        return macOS
    #elseif os(iOS)
        return macOS
    #endif
}

struct MoviesView: View {
    struct Theme {
        let itemWidth: CGFloat = value(tvOS: 240, macOS: 120)
        let itemSpacing: CGFloat = value(tvOS: 30, macOS: 20)
        let columnSpacing: CGFloat = value(tvOS: 60, macOS: 30)
    }
    static let theme = Theme()
    
    @StateObject var viewModel = MoviesViewModel()

    let columns = [
        GridItem(.adaptive(minimum: theme.itemWidth), spacing: theme.itemSpacing)
//        GridItem(.flexible(), spacing: 80)
    ]
    
    var body: some View {
        ZStack(alignment: .leading) {
            errorView
            ScrollView {
                LazyVGrid(columns: columns, spacing: MoviesView.theme.columnSpacing) {
                    ForEach(viewModel.movies, id: \.self) { movie in
                        NavigationLink(
                            destination: MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie)),
                            label: {
                                MovieView(movie: movie, ratingsLoader: viewModel)
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
                if viewModel.movies.isEmpty {
                    viewModel.loadMovies()
                }
            }
            #if os(tvOS)
            LeftSidePanelView(currentSort: $viewModel.currentFilter, currentGenre: $viewModel.currentGenre)
                .padding(.leading, -50)
            #endif
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
    
    @ViewBuilder
    var errorView: some View {
        if let error = viewModel.error {
            HStack() {
                Spacer()
                ErrorView(error: error)
                    .padding(.bottom, 100)
                Spacer()
            }
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
