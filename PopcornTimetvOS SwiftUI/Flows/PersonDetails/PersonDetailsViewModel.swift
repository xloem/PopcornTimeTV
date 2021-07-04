//
//  PersonDetailsViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 04.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

class PersonDetailsViewModel: ObservableObject {
    var person: Person
    
    @Published var isLoading = false
    var didLoad = false
    
    var error: Error?
    var shows: [Show] = []
    var movies: [Movie] = []
    
    init(person: Person) {
        self.person = person
    }
    
    func load() {
        guard !isLoading && !didLoad else {
            return
        }
        
        isLoading = true
        let group = DispatchGroup()
        
        group.enter()
        TraktManager.shared.getMediaCredits(forPersonWithId: person.imdbId, mediaType: Show.self) { [weak self] data, error in
            self?.shows = data.uniqued
            self?.error = error
            group.leave()
        }
        
        group.enter()
        TraktManager.shared.getMediaCredits(forPersonWithId: person.imdbId, mediaType: Movie.self) {[weak self] data, error in
            self?.movies = data.uniqued
            self?.error = error
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            self?.didLoad = true
        }
    }
}
