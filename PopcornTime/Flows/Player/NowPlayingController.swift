//
//  NowPlayingController.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 21.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import MediaPlayer
#if os(tvOS)
import TVVLCKit
#elseif os(iOS)
import MobileVLCKit
#elseif os(macOS)
import VLCKit
#endif
import PopcornKit
import Kingfisher

class NowPlayingController {
    private (set) var mediaplayer: VLCMediaPlayer
    private (set) var media: Media
    private var imageGenerator: AVAssetImageGenerator
    var onPlayPause: () -> Void = {}
    
    internal var nowPlayingInfo: [String: Any]? {
        get {
            return MPNowPlayingInfoCenter.default().nowPlayingInfo
        } set {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = newValue
        }
    }
    
    internal var streamDuration: Float {
        guard let remaining = mediaplayer.remainingTime?.value?.floatValue, let elapsed = mediaplayer.time?.value?.floatValue else {
            return Float(CMTimeGetSeconds(imageGenerator.asset.duration) * 1000)
        }
        return fabsf(remaining) + elapsed
    }
    
    init(mediaplayer: VLCMediaPlayer, media: Media, imageGenerator: AVAssetImageGenerator) {
        self.mediaplayer = mediaplayer
        self.media = media
        self.imageGenerator = imageGenerator
    }
    
    func addRemoteCommandCenterHandlers() {
        
        let center = MPRemoteCommandCenter.shared()
            
        center.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.onPlayPause()
            return self.mediaplayer.state == .paused ? .success : .commandFailed
        }
        
        center.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.onPlayPause()
            return self.mediaplayer.state == .playing ? .success : .commandFailed
        }
        
        center.changePlaybackPositionCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.mediaplayer.time = VLCTime(number: NSNumber(value: (event as! MPChangePlaybackPositionCommandEvent).positionTime * 1000))
            return .success
        }
        
        center.stopCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.mediaplayer.stop()
            return .success
        }
        
        center.changePlaybackRateCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.mediaplayer.rate = (event as! MPChangePlaybackRateCommandEvent).playbackRate
            return .success
        }
        
        center.skipForwardCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.mediaplayer.jumpForward(Int32((event as! MPSkipIntervalCommandEvent).interval))
            return .success
        }
        
        center.skipBackwardCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.mediaplayer.jumpBackward(Int32((event as! MPSkipIntervalCommandEvent).interval))
            return .success
        }
    }
    
    func removeRemoteCommandCenterHandlers() {
        nowPlayingInfo = nil
        #if os(iOS) || os(tvOS)
        UIApplication.shared.endReceivingRemoteControlEvents()
        #endif
    }
    
    func configureNowPlayingInfo() {
        nowPlayingInfo = [MPMediaItemPropertyTitle: media.title,
                          MPMediaItemPropertyPlaybackDuration: TimeInterval(streamDuration/1000),
                          MPNowPlayingInfoPropertyElapsedPlaybackTime: mediaplayer.time.value.doubleValue/1000,
                          MPNowPlayingInfoPropertyPlaybackRate: Double(mediaplayer.rate),
                          MPMediaItemPropertyMediaType: MPMediaType.movie.rawValue]
        
        if let image = media.mediumCoverImage ?? media.mediumBackgroundImage, let imageUrl = URL(string: image) {
            let imageResouce = ImageResource(downloadURL: imageUrl)
            KingfisherManager.shared.retrieveImage(with: imageResouce) { result in
                guard let image = result.value?.image else {
                    return
                }

                self.nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            }
        }
    }
    
    func configureNowPlayingPositions() {
        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = TimeInterval(streamDuration/1000)
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = mediaplayer.time.value.doubleValue/1000
        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = mediaplayer.rate
    }
    
    #if os(iOS) || os(tvOS)
    func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else { return }
        
        switch event.subtype {
            case .remoteControlPlay:
                fallthrough
            case .remoteControlPause:
                fallthrough
            case .remoteControlTogglePlayPause:
                self.onPlayPause()
            case .remoteControlStop:
                mediaplayer.stop()
            default:
                break
        }
    }
    #endif
    
    func screenshotAtTime(_ time: NSNumber) -> CGImage? {
        guard let image = try? imageGenerator.copyCGImage(at: CMTimeMakeWithSeconds(time.doubleValue/1000.0, preferredTimescale: 1000), actualTime: nil) else {
            return nil
        }
        return image
    }
    
    func screenshot(at progress: Float) -> CGImage? {
        let currentTime = NSNumber(value: progress * streamDuration)
        return screenshotAtTime(currentTime)
    }
}
