//
//  SearchViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 27.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

class SearchViewModel: ObservableObject {
    enum SearchType: Int {
        case movies = 0, shows, people
    }
    
    @Published var search = ""
    @Published var selection: SearchType = .movies
}
