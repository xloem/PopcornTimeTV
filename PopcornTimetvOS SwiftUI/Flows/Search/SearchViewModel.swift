//
//  SearchViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 27.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

class SearchViewModel: ObservableObject {
    enum SearchType: Int {
        case movies = 0, shows, people
    }
    
    @Published var search = ""
    @Published var selection: SearchType = .movies
    @Published var isLoading = false
    
    @Published var movies: [Movie] = []
    @Published var shows: [Show] = []
    @Published var persons: [Person] = []
    @Published var error: Error?
    var onTextChange: Any?
    
    init() {
        self.onTextChange = self.$search
//            .filter({ $0.count > 2})
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: RunLoop.main).sink(receiveValue: { [weak self] value in
            self?.filterSearchText(value)
        })
    }
    
    func filterSearchText(_ text: String) {
        guard text.count > 2 else {
            isLoading = false
            persons = []
            movies = []
            shows = []
            return
        }
        
        isLoading = true
        
        switch selection {
        case .movies:
            PopcornKit.loadMovies(searchTerm: text) { movies, error in
                self.movies = movies ?? []
                self.error = error
                self.isLoading = false
            }
        case .shows:
            PopcornKit.loadShows(searchTerm: text) { shows, error in
                self.shows = shows ?? []
                self.error = error
                self.isLoading = false
            }
        case .people:
            TraktManager.shared.search(forPerson: text) { persons, error in
                self.persons = persons ?? []
                self.error = error
                self.isLoading = false
            }
        }
    }
}
