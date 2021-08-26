//
//  PlayerAudioController.swift
//  PlayerAudioController
//
//  Created by Alexandru Tudose on 26.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import SwiftUI
#if os(tvOS)
import TVVLCKit
#elseif os(iOS)
import MobileVLCKit
#elseif os(macOS)
import VLCKit
#endif
import AVKit

class PlayerAudioModel {
    private (set) var mediaplayer: VLCMediaPlayer
    var audioProfile: EqualizerProfiles = .fullDynamicRange
    var audioProfileBinding: Binding<EqualizerProfiles> = .constant(.fullDynamicRange)
    var audioDelayBinding: Binding<Int> = .constant(0)
    
    init(mediaplayer: VLCMediaPlayer) {
        self.mediaplayer = mediaplayer
        
        audioDelayBinding = Binding(get: {
            mediaplayer.currentAudioPlaybackDelay
        }, set: { newDelay in
            mediaplayer.currentAudioPlaybackDelay = newDelay
        })
        
        audioProfileBinding = Binding(get: { [unowned self] in
            return audioProfile
        }, set: { [unowned self] profile in
            audioProfile = profile
            didSelectEqualizerProfile(profile)
        })
        
        #if os(iOS) || os(tvOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.allowBluetoothA2DP,.allowAirPlay])

        didSelectEqualizerProfile(.fullDynamicRange)
        #endif
    }
    
    func didSelectEqualizerProfile(_ profile: EqualizerProfiles) {
        mediaplayer.resetEqualizer(fromProfile: profile.rawValue)
        mediaplayer.equalizerEnabled = true
    }
}
