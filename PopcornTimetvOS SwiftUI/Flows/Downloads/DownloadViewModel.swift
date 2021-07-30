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
    
    var playerModel: PlayerViewModel?
    var preloadTorrentModel: PreloadTorrentViewModel?
    
    @Published var selection: Selection? = nil
    
    enum Selection: Int, Identifiable {
        case preload = 2
        case play = 3
        var id: Int { return rawValue }
    }
    
    init(download: PTTorrentDownload) {
        self.download = download
        status = download.torrentStatus
        super.init()
        
        observation = download.observe(\.torrentStatus) { [weak self] download, change in
            self?.status = download.torrentStatus
        }
    }
    
    func delete() {
        PTTorrentDownloadManager.shared().delete(download)
    }
    
    func play() {
        let media: Media = Movie(download.mediaMetadata) ?? Episode(download.mediaMetadata)!
        // No torrent metadata necessary, media
        self.preloadTorrentModel = PreloadTorrentViewModel(torrent: Torrent(), media: media, onReadyToPlay: { [weak self] playerModel in
            self?.playerModel = playerModel
            self?.selection = .play
        })
        self.selection = .preload
    }
    
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
