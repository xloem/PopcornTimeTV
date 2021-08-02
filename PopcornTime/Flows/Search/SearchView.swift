//
//  SearchView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import SwiftUIFocusGuide

struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    @StateObject var focusBag = SwiftUIFocusBag()
    
    var body: some View {
        ZStack {
            VStack {
            SearchWrapperView(text: $viewModel.search,
                              selection: $viewModel.selection,
                              scopesTitles: ["Movies".localized,
                                             "Shows".localized,
                                             "People".localized])
                .addFocusGuide(using: focusBag, name: "Search", destinations: [.bottom: "Results"], debug: true)
                Spacer(minLength: 475)
            }
            VStack {
                Spacer(minLength: 400)
                errorView
                if viewModel.isLoading {
                    ProgressView()
                }
                switch viewModel.selection {
                case .movies:
                    moviesSection
                        .addFocusGuide(using: focusBag, name: "Results", destinations: [.top: "Search", .bottom: "Search"], debug: true)
                case .shows:
                    showsSection
                        .addFocusGuide(using: focusBag, name: "Results", destinations: [.top: "Search", .bottom: "Search"])
                case .people:
                    peopleSection
                        .addFocusGuide(using: focusBag, name: "Results", destinations: [.top: "Search", .bottom: "Search"])
                }
            }
        }
    }
    
    @ViewBuilder
    var moviesSection: some View {
        if viewModel.movies.isEmpty && !viewModel.isLoading {
            emptyView
        } else {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 40) {
                    ForEach(viewModel.movies, id: \.self) { movie in
                        NavigationLink(
                            destination: MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie)),
                            label: {
                                MovieView(movie: movie)
                                    .frame(width:250, height: 460)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var showsSection: some View {
        if viewModel.shows.isEmpty && !viewModel.isLoading {
            emptyView
        } else {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 40) {
                    ForEach(viewModel.shows, id: \.self) { show in
                        NavigationLink(
                            destination: ShowDetailsView(viewModel: ShowDetailsViewModel(show: show)),
                            label: {
                                ShowView(show: show)
                                    .frame(width:250, height: 460)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var peopleSection: some View {
        if viewModel.persons.isEmpty && !viewModel.isLoading {
            emptyView
        } else {
            let persons = viewModel.persons
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 40) {
                    ForEach(0..<persons.count, id: \.self) { index in
                        NavigationLink(
                            destination: PersonDetailsView(viewModel: PersonDetailsViewModel(person: persons[index])),
                            label: {
                                PersonView(person: persons[index])
                                    .frame(width: 220)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
                    }
                }
                .frame(height: 321)
                Spacer()
            }
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
    
    @ViewBuilder
    var emptyView: some View {
        if viewModel.search.count > 0 && viewModel.error == nil {
            let openQuote = Locale.current.quotationBeginDelimiter ?? "\""
            let closeQuote = Locale.current.quotationEndDelimiter ?? "\""
            let description = String.localizedStringWithFormat("We didn't turn anything up for %@. Try something else.".localized, "\(openQuote + viewModel.search + closeQuote)")
            
            VStack {
                Spacer()
                Text("No results".localized)
                    .font(.title2)
                    .padding()
                Text(description)
                    .font(.callout)
                    .foregroundColor(.init(white: 1.0, opacity: 0.667))
                    .frame(maxWidth: 400)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
