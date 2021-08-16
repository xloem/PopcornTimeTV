//
//  PreloadTorrentViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 20.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import PopcornKit
import PopcornTorrent
import MediaPlayer.MPMediaItem
#if canImport(UIKit)
import UIKit
#endif

class PreloadTorrentViewModel: ObservableObject {
    var torrent: Torrent
    var media: Media
    var watchedProgress: Float = 0.0
    
    @Published var isProcessing = true
    @Published var progress: Float = 0.0
    @Published var speed: Int = 0
    @Published var seeds: Int = 0
    var streamer: PTTorrentStreamer?
    
    @Published var error: Error?
    @Published var showError = false
    @Published var showFileToPlay = false
    @Published var playerModel: PlayerViewModel?
    
    var onReadyToPlay: (PlayerViewModel) -> Void
    
    init(torrent: Torrent, media: Media, onReadyToPlay: @escaping (PlayerViewModel) -> Void) {
        self.torrent = torrent
        self.media = media
        self.onReadyToPlay = onReadyToPlay
    }
    
    func cancel() {
        let isPlaying = playerModel != nil
        if !isPlaying {
            self.streamer?.cancelStreamingAndDeleteData(false)
        }
    }
    
    func playTorrent() {
        if let _ = media as? Movie {
            watchedProgress = WatchedlistManager<Movie>.movie.currentProgress(media.id)
        } else if let _ = media as? Episode {
            watchedProgress = WatchedlistManager<Episode>.episode.currentProgress(media.id)
        }
        
        #if os(iOS) || os(tvOS)
        UIApplication.shared.isIdleTimerDisabled = true
        let finishedLoading: () -> Void = {
            UIApplication.shared.isIdleTimerDisabled = false
//            let flag = UIDevice.current.userInterfaceIdiom != .tv
        }
        #else
        let finishedLoading: () -> Void = { }
        #endif
        
        self.media.getSubtitles { [unowned self] subtitles in
            media.subtitles = subtitles
            self.play(fromFileOrMagnetLink: torrent.url, nextEpisodeInSeries: nil, finishedLoadingBlock: finishedLoading)
        }
    }
    

    
    /**
     Start playing movie or episode locally.
     
     - Parameter fromFileOrMagnetLink:  The url pointing to a .torrent file, a web adress pointing to a .torrent file to be downloaded or a magnet link.
     - Parameter nextEpisodeInSeries:   If media is an episode, pass in the next episode of the series, if applicable, for a better UX for the user.
     - Parameter finishedLoadingBlock:  Block thats called when torrent is finished loading.
     */
    func play(
        fromFileOrMagnetLink url: String,
        nextEpisodeInSeries nextEpisode: Episode? = nil,
        finishedLoadingBlock: @escaping () -> Void)
    {
        let playBlock: (URL, URL, Media, Episode?) -> Void = { (videoFileURL, videoFilePath, media, nextEpisode) in
            DispatchQueue.main.async {
                let playerModel = PlayerViewModel(media: media, fromUrl: videoFileURL, localUrl: videoFilePath, directory: videoFilePath.deletingLastPathComponent(), streamer: self.streamer!)
                playerModel.startPosition = self.watchedProgress
                finishedLoadingBlock()
                self.playerModel = playerModel
                self.onReadyToPlay(playerModel)
            }
        }
        
        if hasDownloaded, let download = associatedDownload {
            download.play { (videoFileURL, videoFilePath) in
                self.streamer = download
                playBlock(videoFileURL, videoFilePath, self.media, nextEpisode)
            }
            return
        }
        
        if isDownloading, let download = associatedDownload {
            download.play { (videoFileURL, videoFilePath) in
                self.streamer = download
                playBlock(videoFileURL, videoFilePath, self.media, nextEpisode)
            }
            return
        }
        
        let loadingBlock: (PTTorrentStatus) -> Void = { status in
            self.isProcessing = false
            self.progress = status.bufferingProgress
            self.speed = Int(status.downloadSpeed)
            self.seeds = Int(status.seeds)
        }
        let errorBlock: (Error) -> Void = { error in
            self.error = error
            self.showError = true
        }

        
        PTTorrentStreamer.shared().cancelStreamingAndDeleteData(false) // Make sure we're not already streaming
        
        if url.hasPrefix("magnet") || (url.hasSuffix(".torrent") && !url.hasPrefix("http")) {
            self.streamer = .shared()
            self.streamer!.startStreaming(fromFileOrMagnetLink: url, progress: { (status) in
                loadingBlock(status)
            }, readyToPlay: { (videoFileURL, videoFilePath) in
                playBlock(videoFileURL, videoFilePath, self.media, nextEpisode)
            }, failure: { error in
                errorBlock(error)
            })
        } else {
            PopcornKit.downloadTorrentFile(url, completion: { (url, error) in
                guard let url = url, error == nil else {
                    errorBlock(error ?? NSError(domain: "unknow", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unknown error"]))
                    return
                }
                
                self.play(fromFileOrMagnetLink: url, nextEpisodeInSeries: nil, finishedLoadingBlock: finishedLoadingBlock)
            })
        }
    }
    
    /// The download, either completed or downloading, that is associated with this media object.
    var associatedDownload: PTTorrentDownload? {
        let id = self.media.id
        let array = PTTorrentDownloadManager.shared().activeDownloads + PTTorrentDownloadManager.shared().completedDownloads
        return array.first(where: {($0.mediaMetadata[MPMediaItemPropertyPersistentID] as? String) == id})
    }
    
    /// Boolean value indicating whether the media is currently downloading.
    var isDownloading: Bool {
        let id = self.media.id
        return PTTorrentDownloadManager.shared().activeDownloads.first(where: {($0.mediaMetadata[MPMediaItemPropertyPersistentID] as? String) == id}) != nil
    }
    
    /// Boolean value indicating whether the media has been downloaded.
    var hasDownloaded: Bool {
        let id = self.media.id
        return PTTorrentDownloadManager.shared().completedDownloads.first(where: {($0.mediaMetadata[MPMediaItemPropertyPersistentID] as? String) == id}) != nil
    }
}
