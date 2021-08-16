//
//  PlayerViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 21.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import PopcornKit
#if os(tvOS)
import TVVLCKit
#elseif os(iOS)
import MobileVLCKit
#elseif os(macOS)
import VLCKit
typealias SiriRemoteGestureRecognizer = Any
#endif
import PopcornTorrent
import AVKit
import MediaPlayer
import SwiftUI


enum TransportBarHint: String {
    case none
    case fastForward = "ScanForward"
    case rewind = "ScanBackward"
    case jumpForward30 = "SkipForward30"
    case jumpBackward30 = "SkipBack30"
}


class PlayerViewModel: NSObject, ObservableObject {
    var media: Media
    private (set) var url: URL
    private (set) var mediaplayer = VLCMediaPlayer()
    private var nowPlaying: NowPlayingController
    
    private (set) var directory: URL
    private (set) var localPathToMedia: URL
    private (set) var streamer: PTTorrentStreamer
    internal var nextEpisode: Episode?
    internal var startPosition: Float = 0.0
    private var idleWorkItem: DispatchWorkItem?
    private let NSNotFound: Int32 = -1
    internal var workItem: DispatchWorkItem?
    internal var torrentStatusChangeObserver: AnyObject?
    
    var resumePlayback = false
    @Published var resumePlaybackAlert = false
    
    @Published var isLoading = true
    @Published var isPlaying = false
    @Published var showControls = false
    @Published var showInfo = false
    var presentationMode: Binding<PresentationMode>?
    
    var audioProfile: EqualizerProfiles = .fullDynamicRange
    var audioProfileBinding: Binding<EqualizerProfiles> = .constant(.fullDynamicRange)
    var audioDelayBinding: Binding<Int> = .constant(0)
    var subtitleEncodingBinding: Binding<String> = .constant("")
    var subtitleDelayBinding: Binding<Int> = .constant(0)
    
    var subtitles: Dictionary<String, [Subtitle]> {
        return media.subtitles
    }
    var currentSubtitle: Subtitle? {
        didSet {
            if let subtitle = currentSubtitle {
                PopcornKit.downloadSubtitleFile(subtitle.link, downloadDirectory: directory, completion: { (subtitlePath, error) in
                    guard let subtitlePath = subtitlePath else { return }
                    self.mediaplayer.addPlaybackSlave(subtitlePath, type: .subtitle, enforce: true)
                })
            } else {
                mediaplayer.currentVideoSubTitleIndex = NSNotFound // Remove all subtitles
            }
        }
    }
    var subtitleBinding: Binding<Subtitle?> = .constant(nil)
    
    public let vlcSettingTextEncoding = "subsdec-encoding"
    struct Progress {
        var progress: Float = 0
        var isBuffering = false
        var bufferProgress: Float = 0
        var isScrubbing = false
        var scrubbingProgress: Float = 0
        var remainingTime: String = ""
        var elapsedTime: String = ""
        var scrubbingTime: String = ""
        var screenshot: CGImage?
        var hint: TransportBarHint = .none
    }
    @Published var progress = Progress()
    
    init(media: Media, fromUrl: URL, localUrl: URL, directory: URL, streamer: PTTorrentStreamer, testingMode: Bool = false) {
        self.media = media
        self.url = fromUrl
        self.localPathToMedia = localUrl
        self.directory = directory
        self.streamer = streamer
        
        let imageGenerator = AVAssetImageGenerator(asset: AVAsset(url: localUrl))
        self.nowPlaying = NowPlayingController(mediaplayer: mediaplayer, media: media, imageGenerator: imageGenerator)

        
        super.init()
        self.nowPlaying.onPlayPause = { [weak self] in
            self?.playandPause()
        }
        
        if (!testingMode) {
            prepare()
        }
        
        audioDelayBinding = Binding(get: { [unowned self] in
            mediaplayer.currentAudioPlaybackDelay
        }, set: { [unowned self] newDelay in
            mediaplayer.currentAudioPlaybackDelay = newDelay
        })
        
        audioProfileBinding = Binding(get: { [unowned self] in
            return audioProfile
        }, set: { [unowned self] profile in
            audioProfile = profile
            didSelectEqualizerProfile(profile)
        })
        
        subtitleDelayBinding = Binding(get: { [unowned self] in
            mediaplayer.currentVideoSubTitleDelay
        }, set: { [unowned self] newDelay in
            mediaplayer.currentVideoSubTitleDelay = newDelay
        })
        
        subtitleEncodingBinding = Binding(get: {
            SubtitleSettings.shared.encoding
        }, set: { [unowned self] encoding in
            let subtitle = SubtitleSettings.shared
            subtitle.encoding = encoding
            subtitle.save()
            mediaplayer.media.addOptions([vlcSettingTextEncoding: encoding])
        })
        
        subtitleBinding = Binding(get: { [unowned self] in
            currentSubtitle
        }, set: { [unowned self] subtitle in
            currentSubtitle = subtitle
        })
    }
    
    func prepare() {
        mediaplayer.delegate = self
        mediaplayer.audio.passthrough = true
        mediaplayer.media = VLCMedia(url: url)
        
        torrentStatusChangeObserver = NotificationCenter.default.addObserver(forName: .PTTorrentStatusDidChange, object: streamer, queue: nil) { [unowned self] notification in
            guard !resumePlaybackAlert else { // will trigger UI invalidation - and screen becomes unresponsive
                return
            }
            progress.bufferProgress = streamer.torrentStatus.totalProgress
        }
        if media.subtitles.count == 0 {
            media.getSubtitles(orWithFilePath: localPathToMedia, completion: { [unowned self] (subtitles) in
                    return self.media.subtitles = subtitles
                })
        }
        let settings = SubtitleSettings.shared
        if let preferredLanguage = settings.language {
            self.currentSubtitle = subtitles[preferredLanguage]?.first
        }
        let vlcAppearance = mediaplayer as VLCFontAppearance
        vlcAppearance.setTextRendererFontSize?(NSNumber(value: settings.size.rawValue))
        vlcAppearance.setTextRendererFontColor?(NSNumber(value: settings.color.hexInt()))
        vlcAppearance.setTextRendererFont?(settings.font.fontName as NSString)
        vlcAppearance.setTextRendererFontForceBold?(NSNumber(booleanLiteral: settings.style == .bold || settings.style == .boldItalic))
        
        mediaplayer.media.addOptions([vlcSettingTextEncoding: settings.encoding])
        
        #if os(iOS) || os(tvOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.allowBluetoothA2DP,.allowAirPlay])
        
        didSelectEqualizerProfile(.fullDynamicRange)
        #endif
    }
    
    func playOnAppear() {
        guard mediaplayer.state == .stopped || mediaplayer.state == .opening else { return }
        
        if startPosition > 0.0 {
            isLoading = false
            resumePlaybackAlert = true
        } else {
            mediaplayer.play()
        }
    }
    func play(resumePlayback:Bool = false) {
        if resumePlayback {
            self.resumePlayback = resumePlayback
        }
        isLoading = true
        mediaplayer.play()
    }
    
    func stop() {
        mediaplayer.stop()
        idleWorkItem?.cancel()
    }
    
    func playandPause() {
        if isLoading {
            return
        }
        
        #if os(tvOS)
        self.clickGesture()
        #else
        isPlaying ? mediaplayer.pause() : mediaplayer.play()
        #endif
    }
    
    func fastForward() {
        if progress.isScrubbing {
            progress.scrubbingProgress += 0.01
            positionSliderDidDrag()
        } else {
            mediaplayer.jumpForward(30)
        }
        
    }
    
    func rewind() {
        if progress.isScrubbing {
            progress.scrubbingProgress -= 0.01
            positionSliderDidDrag()
        } else {
            mediaplayer.jumpBackward(30)
        }
    }
    
    func fastForwardHeld(_ starded: Bool) {
        if starded {
            progress.hint = .fastForward
            if mediaplayer.rate == 1.0 {
                mediaplayer.fastForward(atRate: 20.0)
            }
        } else {
            progress.hint = .none
            mediaplayer.rate = 1.0
            resetIdleTimer()
        }
    }
    
    func rewindHeld(_ starded: Bool) {
        if starded {
            progress.hint = .rewind
            if mediaplayer.rate == 1.0 {
                mediaplayer.rewind(atRate: 20.0)
            }
        } else {
            progress.hint = .none
            mediaplayer.rate = 1.0
            resetIdleTimer()
        }
    }
    
    func clickGesture() {
        if progress.isScrubbing {
            endScrubbing()

            // seek to desired position
            if mediaplayer.isSeekable && progress.progress != progress.scrubbingProgress {
                let streamDuration = nowPlaying.streamDuration
                let time = NSNumber(value: progress.scrubbingProgress * streamDuration)
                mediaplayer.time = VLCTime(number: time)
                // Force a progress change rather than waiting for VLCKit's delegate call to.
                progress.progress = progress.scrubbingProgress
                progress.elapsedTime = progress.scrubbingTime
            }
        } else {
            startScrubbing()
        }
    }
    
    @objc func touchLocationDidChange(_ gesture: SiriRemoteGestureRecognizer) {
        guard progress.isScrubbing && showControls && !progress.isBuffering else {
            return
        }
        
//        print("", gesture.touchLocation)
        
//        progress.hint = .none
//        resetIdleTimer()
//        
//        switch gesture.touchLocation {
//        case .left:
//            if gesture.isClick && gesture.state == .ended {
//                rewind()
//                progress.hint = .none
//            }
//            if gesture.isLongPress {
//                rewindHeld(gesture)
//            } else if gesture.state != .ended {
//                progress.hint = .jumpBackward30
//            }
//        case .right:
//            if gesture.isClick && gesture.state == .ended {
//                fastForward()
//                progress.hint = .none
//            }
//            if gesture.isLongPress {
//                fastForwardHeld(gesture)
//            } else if gesture.state != .ended {
//                progress.hint = .jumpForward30
//            }
//        default: return
//        }
    }
    
    func handlePositionSliderDrag(offset: Float) {
        guard showControls && progress.isScrubbing else {
            return
        }
        
        progress.scrubbingProgress += offset
        positionSliderDidDrag()
    }
    
    func positionSliderDidDrag() {
        let streamDuration = nowPlaying.streamDuration
        let time = NSNumber(value: progress.scrubbingProgress * streamDuration)
        let remainingTime = NSNumber(value: time.floatValue - streamDuration)
        progress.remainingTime = VLCTime(number: remainingTime).stringValue
        progress.scrubbingTime = VLCTime(number: time).stringValue
        workItem?.cancel()
        workItem = DispatchWorkItem { [weak self] in
            self?.progress.screenshot = self?.nowPlaying.screenshotAtTime(time)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem!)
    }
    
    func toggleControlsVisible() {
        showControls.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.resetIdleTimer()
        }
    }

    func endScrubbing() {
        mediaplayer.willPlay ? mediaplayer.play() : ()
        resetIdleTimer()
        progress.isScrubbing = false
        progress.hint = .none
        showControls = false
    }
    
    func startScrubbing() {
        mediaplayer.canPause ? mediaplayer.pause() : ()
//        !isLoading ? toggleControlsVisible() : ()
        progress.isScrubbing = true
        progress.scrubbingProgress = progress.progress
        showControls = true
        
        if let image = nowPlaying.screenshot(at: progress.progress) {
            progress.screenshot = image
        }
    }
    
    func didSelectEqualizerProfile(_ profile: EqualizerProfiles) {
        mediaplayer.resetEqualizer(fromProfile: profile.rawValue)
        mediaplayer.equalizerEnabled = true
    }

    
    func saveMediaProgress(status: Trakt.WatchedStatus) {
        if let movie = media as? Movie {
            WatchedlistManager<Movie>.movie.setCurrentProgress(progress.progress, for: movie.id, with: status)
        } else if let episode = media as? Episode {
            WatchedlistManager<Episode>.episode.setCurrentProgress(progress.progress, for: episode.id, with: status)
        }
    }
    
    func resetIdleTimer() {
        idleWorkItem?.cancel()
        idleWorkItem = DispatchWorkItem() { [unowned self] in
            if showControls && self.mediaplayer.isPlaying && !self.progress.isScrubbing && !self.progress.isBuffering && self.mediaplayer.rate == 1.0
                //&& self.movieView.isDescendant(of: self.view) // If paused, scrubbing, fast forwarding, loading or mirroring, cancel work Item so UI doesn't disappear
            {
                self.toggleControlsVisible()
            }
        }
        
        #if os(tvOS)
        let delay: TimeInterval = 3
        #else
        let delay: TimeInterval = 5
        #endif
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: idleWorkItem!)
    }
    
    func didFinishPlaying() {
        mediaplayer.delegate = nil
        mediaplayer.stop()
        
        nowPlaying.removeRemoteCommandCenterHandlers()
//        endReceivingScreenNotifications()
        
        streamer.cancelStreamingAndDeleteData(Session.removeCacheOnPlayerExit)
        
        saveMediaProgress(status: .finished)
        NotificationCenter.default.removeObserver(self, name: .PTTorrentStatusDidChange, object: nil)
        
        presentationMode?.wrappedValue.dismiss()
    }
    
    @Published var videoAspectRatio: SwiftUI.ContentMode = .fit
    func switchVideoDimensions() {
        #if os(iOS)
        resetIdleTimer()
        if mediaplayer.videoCropGeometry == nil // Change to aspect to scale to fill
        {
            let screen =  UIScreen.screens.count > 1 ? UIScreen.screens[1] : UIScreen.main
            mediaplayer.videoCropGeometry = UnsafeMutablePointer<Int8>(mutating: (screen.aspectRatio as NSString).utf8String)
//            screenshotImageView!.contentMode = .scaleAspectFill
        } else // Change aspect ratio to scale to fit
        {
            mediaplayer.videoAspectRatio = nil
            mediaplayer.videoCropGeometry = nil
//            screenshotImageView!.contentMode = .scaleAspectFit
        }
        #endif
    }
}

extension PlayerViewModel: VLCMediaPlayerDelegate {
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        if isLoading {
            isLoading = false

            nowPlaying.addRemoteCommandCenterHandlers()
//            beginReceivingScreenNotifications()
            nowPlaying.configureNowPlayingInfo()

            resetIdleTimer()
        } else {
            nowPlaying.configureNowPlayingPositions()
        }
        
        if resumePlayback && mediaplayer.isSeekable {
            let streamDuration = nowPlaying.streamDuration
            resumePlayback = streamDuration == 0 // check if the current stream length is available if not retry to go to previous position
            if resumePlayback == false {
                let time = NSNumber(value: startPosition * streamDuration)
                mediaplayer.time = VLCTime(number: time)
            }
        }
        
        isPlaying = true
//        playPauseButton?.setImage(UIImage(named: "Pause"), for: .normal)
        
        progress.isBuffering = false
        progress.remainingTime = mediaplayer.remainingTime.stringValue
        progress.elapsedTime = mediaplayer.time.stringValue
        progress.progress = mediaplayer.position
        
//        if nextEpisode != nil && (mediaplayer.remainingTime.intValue/1000) == -31 && presentedViewController == nil {
//            performSegue(withIdentifier: "showUpNext", sender: nil)
//        } else if (mediaplayer.remainingTime.intValue/1000) < -31, let vc = presentedViewController as? UpNextViewController {
//            vc.dismiss(animated: true)
//        }
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        nowPlaying.configureNowPlayingPositions()
        resetIdleTimer()
        progress.isBuffering = false
        switch mediaplayer.state {
        case .error:
            fallthrough
        case .ended:
            fallthrough
        case .stopped:
            didFinishPlaying()
        case .paused:
            saveMediaProgress(status: .paused)
            isPlaying = false
        case .playing:
            isPlaying = true
            saveMediaProgress(status: .watching)
        case .buffering:
            progress.isBuffering = true
        case .opening:
            break
        case .esAdded:
            break
        @unknown default:
            break
        }
    }
}
