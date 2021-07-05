//
//  DownloadButtonViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 24.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornTorrent
import PopcornKit
import MediaPlayer
import Combine

class DownloadButtonViewModel: NSObject, ObservableObject {
    var media: Media
    var torrent: Torrent?
    @Published var state: State = .normal
    @Published var showStopDownloadAlert = false
    @Published var showDownloadFailedAlert = false
    @Published var showDownloadedActionSheet = false
    @Published var downloadError: Error?
    @Published var downloadProgress: Float = 0
    
    var playerModel: PlayerViewModel?
    var preloadTorrentModel: PreloadTorrentViewModel?
    var listenForReadToPlay: AnyCancellable?
    @Published var selection: Selection? = nil
    
    enum Selection: Int, Identifiable {
        case preload = 2
        case play = 3
        var id: Int { return rawValue }
    }
    
    enum State: CaseIterable {
        case normal
        case pending
        case downloading
        case paused
        case downloaded
        
        init(_ downloadStatus: PTTorrentDownloadStatus) {
            switch downloadStatus {
            case .downloading: self = .downloading
            case .paused: self = .paused
            case .processing: self = .pending
            case .finished: self = .downloaded
            case .failed: self = .normal
            @unknown default:
                fatalError()
            }
        }
    }
    
    init(media: Media) {
        self.media = media
        state = media.associatedDownload.flatMap{ State($0.downloadStatus) } ?? .normal
        super.init()
        PTTorrentDownloadManager.shared().add(self)
    }
    
    deinit {
        PTTorrentDownloadManager.shared().remove(self)
    }
    
    func download(torrent: Torrent) {
        PTTorrentDownloadManager.shared().startDownloading(fromFileOrMagnetLink:  torrent.url, mediaMetadata: self.media.mediaItemDictionary)
        print("download torrent", torrent)
        state = .pending
    }
    
    func stopDownload() {
        guard let download = media.associatedDownload else { return }
        PTTorrentDownloadManager.shared().stop(download)
        state = .normal
    }
    
    func play() {
        guard let download = media.associatedDownload else { return }
//        AppDelegate.shared.play(Movie(download.mediaMetadata) ?? Episode(download.mediaMetadata)!, torrent: Torrent()) // No torrent metadata necessary, media
        self.preloadTorrentModel = PreloadTorrentViewModel(torrent: Torrent(), media: Movie(download.mediaMetadata)!)
        self.selection = .preload
        self.listenForReadToPlay = self.preloadTorrentModel?.objectWillChange.sink(receiveValue: { _ in
            if let playerModel = self.preloadTorrentModel?.playerModel {
                self.playerModel = playerModel
                self.selection = .play
            }
        })
    }
    
    func deleteDownload() {
        guard let download = media.associatedDownload else { return }
        PTTorrentDownloadManager.shared().delete(download)
        state = .normal
    }
    
    func resumeDownload() {
        guard let download = media.associatedDownload else { return }
        download.resume()
        state = .downloading
    }
}

extension DownloadButtonViewModel: PTTorrentDownloadManagerListener {
    func torrentStatusDidChange(_ torrentStatus: PTTorrentStatus, for download: PTTorrentDownload) {
        guard download == media.associatedDownload else { return }
        downloadProgress = torrentStatus.totalProgress
        print("download progress", downloadProgress)
    }
    
    func downloadStatusDidChange(_ downloadStatus: PTTorrentDownloadStatus, for download: PTTorrentDownload) {
        guard download == media.associatedDownload else { return }
        state = State(downloadStatus)
    }
    
    func downloadDidFail(_ download: PTTorrentDownload, withError error: Error) {
        guard download == media.associatedDownload else { return }
        
        downloadError = error
        showDownloadFailedAlert = true
    }
}
