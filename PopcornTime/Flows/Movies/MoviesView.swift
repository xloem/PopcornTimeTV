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
    static let theme = Theme()
    
    @StateObject var viewModel = MoviesViewModel()
    let columns = [
        GridItem(.adaptive(minimum: theme.itemWidth), spacing: theme.itemSpacing)
//        GridItem(.flexible(), spacing: 80)
    ]
#if os(tvOS) || os(iOS)
    let willEnterForegroundNotification = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
#endif
    var body: some View {
        ZStack(alignment: .leading) {
            errorView
            ScrollView {
                #if os(iOS)
                filtersView
                #endif
                LazyVGrid(columns: columns, spacing: MoviesView.theme.columnSpacing) {
                    ForEach(viewModel.movies, id: \.self) { movie in
                        navigationLink(movie: movie)
                    }
                    if (!viewModel.movies.isEmpty) {
                        loadingView
                    }
                }
                .padding(.all, 0)
                
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
        #if os(tvOS) || os(iOS)
        .onReceive(willEnterForegroundNotification) { _ in
            viewModel.appDidBecomeActive()
        }
        #endif
        #if os(iOS)
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    @ViewBuilder
    func navigationLink(movie: Movie) -> some View {
        NavigationLink(
            destination: { MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie)) },
            label: {
                MovieView(movie: movie, ratingsLoader: viewModel)
            })
            .buttonStyle(PlainNavigationLinkButtonStyle())
            .padding([.leading, .trailing], 10)
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
        if let error = viewModel.error, viewModel.movies.isEmpty {
            HStack() {
                Spacer()
                ErrorView(error: error)
                    .padding(.bottom, 100)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var filtersView: some View {
        HStack(spacing: 0) {
            Picker("Movies", selection: $viewModel.currentFilter) {
                ForEach(MovieManager.Filters.allCases, id: \.self) { item in
                    Text(item.string).tag(item)
                }
            
            }
            Text("Movies - Genre")
                .padding(.horizontal, 5)
            Picker("Genre", selection: $viewModel.currentGenre) {
                ForEach(MovieManager.Genres.allCases, id: \.self) { item in
                    Text(item.string).tag(item)
                }
            }
        }
        .foregroundColor(.appSecondary)
        .font(.callout)
    }
}

extension MoviesView {
    struct Theme {
        let itemWidth: CGFloat = value(tvOS: 240, macOS: 160)
        let itemSpacing: CGFloat = value(tvOS: 30, macOS: 20)
        let columnSpacing: CGFloat = value(tvOS: 60, macOS: 30)
    }
}

struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MoviesViewModel()
        model.movies = Movie.dummiesFromJSON()
        return MoviesView(viewModel: model)
            .preferredColorScheme(.dark)
            .accentColor(.white)
    }
}
