//
//  PlayerOptionsView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 25.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
#if os(tvOS)
import TVVLCKit
#elseif os(iOS)
import MobileVLCKit
#elseif os(macOS)
import VLCKit
#endif

struct PlayerOptionsView: View {
    var media: Media?
    let height: CGFloat = 440
    @State var selectedTab = Selection.info
    @Binding var audioDelay: Int
    @Binding var audioProfile: EqualizerProfiles
    @Binding var subtitleDelay: Int
    @Binding var subtitleEncoding: String
    @Binding var subtitle: Subtitle?
    
    enum Selection: Int {
        case info = 0, subtitles, audio
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            InfoView(media: media)
                .tabItem {
                    Text("Info".localized)
                }
                .tag(Selection.info)
            SubtitlesView(currentDelay: $subtitleDelay,
                          currentEncoding: $subtitleEncoding,
                          currentSubtitle: $subtitle,
                          viewModel: SubtitlesViewModel(subtitles: media?.subtitles ?? [:])
                )
                .tabItem {
                    Text("Subtitles".localized)
                }
                .tag(Selection.subtitles)
            AudioView(
                currentDelay: $audioDelay,
                currentSound: $audioProfile)
                .tabItem {
                    Text("Audio".localized)
                }
                .tag(Selection.audio)
        }
        .ignoresSafeArea(.all)
        .frame(maxHeight: height)
        .padding([.bottom], 30)
        .background(VisualEffectBlur().cornerRadius(60).padding(.top, 100))
        .padding([.leading, .trailing], 120)
        .padding([.top], 30)
    }
}

struct PlayerOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                PlayerOptionsView(media: Movie.dummy(),
                                  audioDelay: .constant(0),
                                  audioProfile: .constant(.fullDynamicRange),
                                  subtitleDelay: .constant(0),
                                  subtitleEncoding: .constant(""),
                                  subtitle: .constant(nil))
                Spacer()
            }
            .background(Color.gray)
            .ignoresSafeArea()
            
            VStack {
                PlayerOptionsView(media: Movie.dummy(),
                                  selectedTab: PlayerOptionsView.Selection.subtitles,
                                  audioDelay: .constant(0),
                                  audioProfile: .constant(.fullDynamicRange),
                                  subtitleDelay: .constant(0),
                                  subtitleEncoding: .constant(""),
                                  subtitle: .constant(nil))
                Spacer()
            }
            .background(Color.gray)
            .ignoresSafeArea()
            
            VStack {
                PlayerOptionsView(media: Movie.dummy(),
                                  selectedTab: PlayerOptionsView.Selection.audio,
                                  audioDelay: .constant(0),
                                  audioProfile: .constant(.fullDynamicRange),
                                  subtitleDelay: .constant(0),
                                  subtitleEncoding: .constant(""),
                                  subtitle: .constant(nil))
                Spacer()
            }
            .background(Color.gray)
            .ignoresSafeArea()
        }
    }
}
