//
//  ShowsView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct ShowsView: View {
    struct Theme {
        let itemWidth: CGFloat = value(tvOS: 240, macOS: 160)
        let itemSpacing: CGFloat = value(tvOS: 30, macOS: 20)
        let columnSpacing: CGFloat = value(tvOS: 60, macOS: 30)
    }
    static let theme = Theme()
    
    @StateObject var viewModel = ShowsViewModel()
    let columns = [
        GridItem(.adaptive(minimum: theme.itemWidth), spacing: theme.itemSpacing)
    ]
    
    var body: some View {
        ZStack(alignment: .leading) {
            errorView
            ScrollView {
                LazyVGrid(columns: columns, spacing: ShowsView.theme.columnSpacing) {
                    ForEach(viewModel.shows, id: \.self) { show in
                        NavigationLink(
                            destination: ShowDetailsView(viewModel: ShowDetailsViewModel(show: show)),
                            label: {
                                ShowView(show: show)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
                            .padding([.leading, .trailing], 10)
                    }
                    if (!viewModel.shows.isEmpty) {
                        loadingView
                    }
                }.padding(.all, 0)
                if viewModel.isLoading && viewModel.shows.isEmpty {
                    ProgressView()
                }
            }
            .padding(.horizontal)
            .onAppear {
                if viewModel.shows.isEmpty {
                    viewModel.loadShows()
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
                viewModel.loadShows()
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

struct ShowsView_Previews: PreviewProvider {
    static var previews: some View {
        let model = ShowsViewModel()
        model.shows = Show.dummiesFromJSON()
        return ShowsView(viewModel: model)
            .preferredColorScheme(.dark)
//            .previewInterfaceOrientation(.landscapeLeft)
    }
}
