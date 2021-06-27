//
//  AudioView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import AVFoundation
import PopcornKit
import Combine

enum EqualizerProfiles: UInt32, CaseIterable, Identifiable {
    case fullDynamicRange = 0
    case reduceLoudSounds = 15
    
    var localizedString: String {
        switch self {
        case .fullDynamicRange:
            return "Full Dynamic Range".localized
        case .reduceLoudSounds:
            return "Reduce Loud Sounds".localized
        }
    }
    
    var id: UInt32 {
        return self.rawValue
    }
}

struct AudioView: View {
    @Binding var currentDelay: Int
    @Binding var currentSound: EqualizerProfiles
    @State var manager = AVSpeakerManager()
    @State var triggerRefresh = false
//    @State var routesDidChange = NotificationCenter.default.publisher(for: .AVSpeakerManagerPickableRoutesDidChange).sink { _ in
//        self.triggerRefresh = true
//    }
    
    let delays = (-60..<60)
    let sounds = EqualizerProfiles.allCases
    
    var body: some View {
        HStack (alignment:.top, spacing: 50) {
            Spacer()
            delaySection
                .frame(width: 390)
            soundSection
                .frame(width: 400)
            speakerSection
                .frame(width: 500)
            Spacer()
        }
        .frame(maxHeight: 300)
    }
    
    var delaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(text: "Delay")
            ScrollViewReader { scroll in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(delays) { delay in
                            button(text: delayText(delay: delay), isSelected: delay == currentDelay) {
                                self.currentDelay = delay
                                self.triggerRefresh.toggle()
                            }
                            .id(delay)
                        }
                    }
                }
                .onAppear(perform: {
                    scroll.scrollTo(currentDelay, anchor: .center)
                })
            }
            
        }
    }
    
    var soundSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(text: "Sound")
            VStack(alignment: .leading, spacing: 15) {
                ForEach(sounds) { item in
                    button(text: item.localizedString, isSelected: item == currentSound) {
                        currentSound = item
                        self.triggerRefresh.toggle()
                    }
                }
            }
        }
    }
    
    var speakerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(text: "Speakers")
            VStack(alignment: .leading, spacing: 15) {
                ForEach(0..<manager.speakerRoutes.count, id: \.self) { item in
                    button(text: manager.speakerRoutes[item].name, isSelected: manager.speakerRoutes[item].isSelected) {
                        let route = manager.speakerRoutes[item]
                        manager.select(route: route)
                        triggerRefresh.toggle()
                    }
                }
            }
        }
    }
    
    func delayText(delay: Int) -> String {
        return (delay > 0 ? "+" : "") + NumberFormatter.localizedString(from: NSNumber(value: delay), number: .decimal)
    }
    
    func sectionHeader(text: String) -> some View {
        Text(text.localized.uppercased())
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.init(white: 1, opacity: 0.5))
            .padding(.leading, 50)
    }
    
    func button(text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            HStack(spacing: 20) {
                if (isSelected) {
                    Image(systemName: "checkmark")
                } else {
                    Text("").frame(width: 32)
                }
                Text(text)
                    .font(.system(size: 31, weight: .medium))
            }
        }).buttonStyle(PlainButtonStyle(onFocus: {}))
    }
}


struct AudioView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AudioView(currentDelay: .constant(0),
                      currentSound: .constant(.fullDynamicRange))
        }.previewLayout(.sizeThatFits)
    }
}
