//
//  DownloadViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 25.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornTorrent
import MediaPlayer
import PopcornKit
import Combine

class DownloadViewModel: NSObject, ObservableObject {
    var download: PTTorrentDownload
    
    @Published var showStopDownloadAlert = false
    @Published var showDownloadFailedAlert = false
    @Published var showDownloadedActionSheet = false
    @Published var downloadError: Error?
    @Published var status: PTTorrentStatus
    var observation: NSKeyValueObservation?
    
    init(download: PTTorrentDownload) {
        self.download = download
        status = download.torrentStatus
        super.init()
        
        observation = download.observe(\.torrentStatus) { [weak self] download, change in
            self?.status = download.torrentStatus
        }
    }
    
    func delete() {
        if download.downloadStatus == .processing {
            PTTorrentDownloadManager.shared().pause(download)
        } else {
            PTTorrentDownloadManager.shared().delete(download)
        }
    }
    
    lazy var media: Media = {
        let media: Media = Movie(download.mediaMetadata) ?? Episode(download.mediaMetadata)!
        return media
    }()
    var torrent = Torrent() // No torrent metadata necessary, media
    
    func continueDownload() {
        PTTorrentDownloadManager.shared().resumeDownload(download)
    }
    
    func pause() {
        PTTorrentDownloadManager.shared().pause(download)
    }
}


extension PTTorrentDownload {
    var title: String {
        return mediaMetadata[MPMediaItemPropertyTitle] as? String ?? ""
    }
    
    var smallCoverImage: String? {
        return mediaMetadata[MPMediaItemPropertyBackgroundArtwork]  as? String
    }
    
    var show: Show? {
        Episode(mediaMetadata)?.show
    }
    
    var isEpisode: Bool {
        Episode(mediaMetadata)?.show != nil
    }
    
    var isCompleted: Bool {
        return downloadStatus == .finished
    }
    
    static func dummy(status: PTTorrentDownloadStatus) -> PTTorrentDownload {
        return PTTorrentDownload(mediaMetadata: Movie.dummy().mediaItemDictionary, downloadStatus: status)
    }
    
    static func dummyEpisode(status: PTTorrentDownloadStatus) -> PTTorrentDownload {
        let episode = Episode(JSON: showEpisodesJSON[0])!
        return PTTorrentDownload(mediaMetadata: episode.mediaItemDictionary, downloadStatus: status)
    }
}
