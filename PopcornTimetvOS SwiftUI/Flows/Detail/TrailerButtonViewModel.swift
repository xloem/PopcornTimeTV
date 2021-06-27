//
//  TrailerButtonViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 21.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import AVKit
import XCDYouTubeKit
import PopcornKit

class TrailerButtonViewModel {
    var movie: Movie
    var trailerUrl: URL? // scrapped from youtube
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    var _trailerVidePlayer: AVPlayer?
    var trailerVidePlayer: AVPlayer? {
        guard let url = trailerUrl else { return nil }
        if let player = _trailerVidePlayer {
            return player
        }
        
        let media = self.movie
        let player = AVPlayer(url: url)
        
        let title = self.makeMetadataItem(AVMetadataIdentifier.commonIdentifierArtwork.rawValue, value: media.title)
        let summary = self.makeMetadataItem(AVMetadataIdentifier.commonIdentifierDescription.rawValue, value: media.summary)
        player.currentItem?.externalMetadata = [title, summary]
        
        if let string = media.mediumCoverImage,
            let url = URL(string: string),
            let data = try? Data(contentsOf: url) {
            let image = self.makeMetadataItem(AVMetadataIdentifier.commonIdentifierArtwork.rawValue, value: data as NSData)
            player.currentItem?.externalMetadata.append(image)
        }
        
        _trailerVidePlayer = player
        
        return player
    }
    
    func loadTrailerUrl(_ completion: @escaping (URL) -> Void) {
        guard let id = movie.trailerCode else { return }
        
        if let url = trailerUrl {
            completion(url)
            return
        }
        
        XCDYouTubeClient.default().getVideoWithIdentifier(id) { (video, error) in
            guard
                let streamUrls = video?.streamURLs,
                let qualities = Array(streamUrls.keys) as? [UInt]
                else {
                    return
            }
            
            let preferredVideoQualities = [XCDYouTubeVideoQuality.HD720.rawValue, XCDYouTubeVideoQuality.medium360.rawValue, XCDYouTubeVideoQuality.small240.rawValue]
            var videoUrl: URL? = nil
            
            for quality in preferredVideoQualities {
                if let index = qualities.firstIndex(of: quality) {
                    videoUrl = Array(streamUrls.values)[index]
                    break
                }
            }
            
            guard let url = videoUrl else { return }
            
            self.trailerUrl = url
            completion(url)
        }
    }
    
    private func makeMetadataItem(_ identifier: String, value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = AVMetadataIdentifier(rawValue: identifier)
        item.value = value as? NSCopying & NSObjectProtocol
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }
}
