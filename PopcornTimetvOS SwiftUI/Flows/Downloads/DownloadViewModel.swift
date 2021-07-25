//
//  DownloadsViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 08.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornTorrent
import PopcornKit
import MediaPlayer

class DownloadViewModel: NSObject, ObservableObject {
    @Published var error: Error?
    @Published var hasChanges: Bool = false
    let downloadManager = PTTorrentDownloadManager.shared()
    
    override init() {
        super.init()
        PTTorrentDownloadManager.shared().add(self)
    }
    
    deinit {
        PTTorrentDownloadManager.shared().remove(self)
    }
    
    var isEmpty: Bool {
        return downloadManager.activeDownloads.isEmpty && downloadManager.completedDownloads.isEmpty
    }
    
    var completedEpisodes: [PTTorrentDownload] {
        return filter(downloads: downloadManager.completedDownloads, through: .episode)
    }
    
    var completedMovies: [PTTorrentDownload] {
        return filter(downloads: downloadManager.completedDownloads, through: .movie)
    }
    
    var completedShows: [Show] {
        return completedEpisodes.compactMap({ Episode($0.mediaMetadata)?.show }).uniqued
    }
    
    var downloadingEpisodes: [PTTorrentDownload] {
        return filter(downloads: downloadManager.activeDownloads, through: .episode)
    }
    
    var downloadingMovies: [PTTorrentDownload] {
        return filter(downloads: downloadManager.activeDownloads, through: .movie)
    }
    
    var downloading: [PTTorrentDownload] {
        return downloadManager.activeDownloads
    }
    
    private func filter(downloads: [PTTorrentDownload], through predicate: MPMediaType) -> [PTTorrentDownload] {
        return downloads.filter { download in
            guard let rawValue = download.mediaMetadata[MPMediaItemPropertyMediaType] as? NSNumber else { return false }
            let type = MPMediaType(rawValue: rawValue.uintValue)
            return type == predicate
        }.sorted { (first, second) in
            guard
                let firstTitle = first.mediaMetadata[MPMediaItemPropertyTitle] as? String,
                let secondTitle = second.mediaMetadata[MPMediaItemPropertyTitle] as? String
                else {
                    return false
            }
            return firstTitle > secondTitle
        }
    }
    
}

extension DownloadViewModel: PTTorrentDownloadManagerListener {
    func downloadStatusDidChange(_ downloadStatus: PTTorrentDownloadStatus, for download: PTTorrentDownload) {
        hasChanges.toggle()
    }
    
    func downloadDidFail(_ download: PTTorrentDownload, withError error: Error) {
        self.error = error
    }
}
