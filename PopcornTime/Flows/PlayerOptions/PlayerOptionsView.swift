//
//  PlayerOptionsView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 25.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import TVVLCKit

struct PlayerOptionsView: View {
    var media: Media?
    var mediaplayer: VLCMediaPlayer?
    let height: CGFloat = 440
    @State var selectedTab = 0
    @Binding var audioDelay: Int
    @Binding var audioProfile: EqualizerProfiles
    @Binding var subtitleDelay: Int
    @Binding var subtitleEncoding: String
    @Binding var subtitle: Subtitle?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            InfoView(media: media)
                .tabItem {
                    Text("Info".localized)
                }
                .tag(0)
            SubtitlesView(currentDelay: $subtitleDelay, currentEncoding: $subtitleEncoding, currentSubtitle: $subtitle, subtitles: media?.subtitles ?? [:])
                .tabItem {
                    Text("Subtitles".localized)
                }
                .tag(1)
            AudioView(
                currentDelay: $audioDelay,
                currentSound: $audioProfile)
                .tabItem {
                    Text("Audio".localized)
                }
                .tag(2)
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
                                  selectedTab: 2,
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
                                  selectedTab: 1,
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
