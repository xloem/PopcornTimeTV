//
//  ContentProvider.swift
//  TopShelfSwiftUI
//
//  Created by Alexandru Tudose on 06.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import TVServices
import PopcornKit
import ObjectMapper

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        
        var sections: [TVTopShelfItemCollection<TVTopShelfSectionedItem>] = [
            TVTopShelfItemCollection(items: []),
            TVTopShelfItemCollection(items: [])
        ]
        let group = DispatchGroup()
        
        group.enter()
        PopcornKit.loadMovies(filterBy: .trending) { (movies, error) in
            let items = movies?.prefix(10).map{ self.mapMedia($0) } ?? []
            let section = TVTopShelfItemCollection(items: items)
            section.title = "Trending Movies"
            sections[0] = section
            group.leave()
        }
        
        group.enter()
        PopcornKit.loadShows(filterBy: .trending) { (shows, error) in
            let items = shows?.prefix(10).map{ self.mapMedia($0) } ?? []
            let section = TVTopShelfItemCollection(items: items)
            section.title = "Trending Shows"
            sections[1] = section
            group.leave()
        }
        
        group.notify(queue: .main) {
            let content = TVTopShelfSectionedContent(sections: sections)
            completionHandler(content);
        }
    }
    
    func mapMedia(_ media: Media) -> TVTopShelfSectionedItem {
        let item = TVTopShelfSectionedItem(identifier: media.id)
        item.title = media.title
        item.setImageURL(URL(string: media.mediumCoverImage ?? ""), for: .screenScale1x)
        item.setImageURL(URL(string: media.mediumCoverImage ?? ""), for: .screenScale2x)
        item.imageShape = .poster
//        item.playbackProgress = Double(WatchedlistManager<Movie>.movie.currentProgress(media.id))

        // generate url
        var components = URLComponents()
        components.scheme = AppScheme
        components.queryItems = [URLQueryItem(name: "action", value: toJSONString(media))]
        if let url = components.url {
            item.playAction = TVTopShelfAction(url: url)
            item.displayAction = TVTopShelfAction(url: url)
        }
        
        
        return item
    }
    
    func toJSONString(_ media: Media) -> String {
        switch media {
        case is Movie:
            return "showMovie" + "»" + (media.toJSONString() ?? "")
        case is Show:
            return "showShow" + "»" + (media.toJSONString() ?? "")
        default:
            return ""
        }
    }
}

