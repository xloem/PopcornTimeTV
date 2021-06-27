//
//  DetailViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 20.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import PopcornKit
import AVKit

class DetailViewModel: ObservableObject {
    @Published var movie: Movie
    var error: Error?
    @Published var isLoading = false
    var didLoad = false
    var trailerModel: TrailerButtonViewModel
    var downloadModel: DownloadButtonViewModel
    
    init(movie: Movie) {
        self.movie = movie
        self.trailerModel = TrailerButtonViewModel(movie: movie)
        self.downloadModel = DownloadButtonViewModel(media: movie)
    }
    
    func load() {
        guard !isLoading, !didLoad else {
            return
        }
        
        isLoading = true
        PopcornKit.getMovieInfo(movie.id) { (movie, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            
            let group = DispatchGroup()
                
            group.enter()
            TraktManager.shared.getRelated(self.movie) {arg1,_ in
                self.movie.related = arg1
                print("related \n", arg1)
                
                group.leave()
            }
            
            group.enter()
            TraktManager.shared.getPeople(forMediaOfType: .movies, id: self.movie.id) {arg1,arg2,_ in
                self.movie.actors = arg1
                self.movie.crew = arg2
                print("crew\n", self.movie.crew.toJSON())
                print("actors\n", self.movie.actors.toJSON())
                group.leave()
                self.isLoading = false
            }
            
            group.notify(queue: .main) {
                self.didLoad = true
                print(self.movie.toJSON())
            }
        }
    }
    
    var autoSelectTorrent: Torrent? {
        if let quality = Session.autoSelectQuality {
            let sorted  = movie.torrents.sorted(by: <)
            let torrent = quality == "Highest".localized ? sorted.last! : sorted.first!
            return torrent
        }
        
        if movie.torrents.count == 1 {
            return movie.torrents[0]
        }
        
        return nil
    }
    
    var backgroundUrl: URL {
        return URL(string: movie.largeBackgroundImage ?? "")!
    }
}
