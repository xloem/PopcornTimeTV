//
//  PlayerSubtitleModel.swift
//  PlayerSubtitleModel
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
import PopcornKit

class PlayerSubtitleModel {
    private (set) var media: Media
    private (set) var mediaplayer: VLCMediaPlayer
    private (set) var downloadDirectory: URL
    private let NSNotFound: Int32 = -1
    
    var subtitleEncodingBinding: Binding<String> = .constant("")
    var subtitleDelayBinding: Binding<Int> = .constant(0)
    var subtitleBinding: Binding<Subtitle?> = .constant(nil)
    
    public let vlcSettingTextEncoding = "subsdec-encoding"
    
    init(media: Media, mediaplayer: VLCMediaPlayer, directory: URL, localPathToMedia: URL) {
        self.media = media
        self.mediaplayer = mediaplayer
        self.downloadDirectory = directory
        
        let isSwiftUIPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        
        if !isSwiftUIPreview {
            if media.subtitles.count == 0 {
                media.getSubtitles(orWithFilePath: localPathToMedia, completion: { (subtitles) in
                    self.media.subtitles = subtitles
                })
            }
        }
        
        let settings = SubtitleSettings.shared
        if let preferredLanguage = settings.language {
            self.currentSubtitle = media.subtitles[preferredLanguage]?.first
        }
        let vlcAppearance = mediaplayer as VLCFontAppearance
        vlcAppearance.setTextRendererFontSize?(NSNumber(value: settings.size.rawValue))
        vlcAppearance.setTextRendererFontColor?(NSNumber(value: settings.color.hexInt()))
        vlcAppearance.setTextRendererFont?(settings.font.fontName as NSString)
        vlcAppearance.setTextRendererFontForceBold?(NSNumber(booleanLiteral: settings.style == .bold || settings.style == .boldItalic))
        
        mediaplayer.media.addOptions([vlcSettingTextEncoding: settings.encoding])
        
        subtitleDelayBinding = Binding(get: {
            mediaplayer.currentVideoSubTitleDelay
        }, set: { newDelay in
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
    
    var currentSubtitle: Subtitle? {
        didSet {
            if let subtitle = currentSubtitle {
                PopcornKit.downloadSubtitleFile(subtitle.link, downloadDirectory: downloadDirectory, completion: { (subtitlePath, error) in
                    guard let subtitlePath = subtitlePath else { return }
                    self.mediaplayer.addPlaybackSlave(subtitlePath, type: .subtitle, enforce: true)
                })
            } else {
                mediaplayer.currentVideoSubTitleIndex = NSNotFound // Remove all subtitles
            }
        }
    }
}
