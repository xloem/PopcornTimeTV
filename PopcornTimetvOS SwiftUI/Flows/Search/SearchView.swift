//
//  SearchView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    
    var body: some View {
        VStack {
            SearchWrapperView(text: $viewModel.search)
                .focusable()
            Picker(selection: $viewModel.selection, label: Text("")) {
                Text("Movies".localized).tag(SearchViewModel.SearchType.movies)
                Text("Shows".localized).tag(SearchViewModel.SearchType.shows)
                Text("People".localized).tag(SearchViewModel.SearchType.people)
            }
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
