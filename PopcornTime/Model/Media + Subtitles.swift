//
//  Media + Subtitles.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 21.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import PopcornKit

extension Media {
    /**
     Retrieves subtitles from OpenSubtitles
     
     - Parameter id:    `nil` by default. The imdb id of the media will be used by default.
     
     - Parameter completion: The completion handler for the request containing an array of subtitles
     */
    func getSubtitles(forId id: String? = nil, orWithFilePath: URL? = nil, forLang:String? = nil, completion: @escaping (Dictionary<String, [Subtitle]>) -> Void) {
        let id = id ?? self.id
        if let filePath = orWithFilePath {
            SubtitlesManager.shared.search(preferredLang: "el", videoFilePath: filePath){ (subtitles, _) in
                completion(subtitles)
            }
        } else if let episode = self as? Episode, !id.hasPrefix("tt"), let show = episode.show {
            TraktManager.shared.getEpisodeMetadata(show.id, episodeNumber: episode.episode, seasonNumber: episode.season) { (episode, _) in
                if let imdb = episode?.imdbId {
                    return self.getSubtitles(forId: imdb, completion: completion)
                }
                
                SubtitlesManager.shared.search(episode) { (subtitles, _) in
                    completion(subtitles)
                }
            }
        } else {
            SubtitlesManager.shared.search(imdbId: id) { (subtitles, _) in
                completion(subtitles)
            }
        }
    }
}
