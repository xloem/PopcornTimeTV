//
//  SubtitlesView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct SubtitlesView: View {
    @Binding var currentDelay: Int
    @Binding var currentEncoding: String
    @Binding var currentSubtitle: Subtitle?
    @State var triggerRefresh = false
    @State var showExtendedSubtitles = false
    
    let delays = (-60..<60)
    var subtitles = Dictionary<String, [Subtitle]>()
    let encodings = SubtitleSettings.encodings
    var encodingsKeys: [String] = Array(SubtitleSettings.encodings.keys.sorted())
    
    @State var subtitlesInView: [Subtitle] = []
    let enLocale = Locale.current.localizedString(forLanguageCode: "en")!
    let selectOther = "Select Other".localized
    
    var body: some View {
        HStack (alignment:.top, spacing: 0) {
            Spacer()
            languageSection
                .frame(width: 390)
            delaySection
            encodingSection
            Spacer()
        }
        .frame(maxHeight: 300)
    }
    
    var languageSection: some View {
        Group {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(text: "Language")
                if subtitles.isEmpty {
                    Text("No subtitles available.".localized)
                        .foregroundColor(.init(white: 1, opacity: 0.5))
                        .font(.system(size: 35, weight: .medium))
                        .padding(.leading, 20)
                } else {
                    ScrollViewReader { scroll in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(subtitlesInView) { subtitle in
                                    button(text: subtitle.language, isSelected: subtitle.language == currentSubtitle?.language) {
                                        if subtitle.language == selectOther {
                                            self.showExtendedSubtitles = true
                                        } else {
                                            self.currentSubtitle = self.currentSubtitle == subtitle ? nil : subtitle
                                            self.triggerRefresh.toggle()
                                        }
                                    }
//                                    .prefersDefaultFocus(subtitle.language == currentSubtitle?.language, in: namespace)
                                    .id(subtitle.language)
                                }
                            }
                        }
                        .onAppear(perform: {
                            self.subtitlesInView = self.generateSubtitles()
                            scroll.scrollTo(currentSubtitle?.language, anchor: .center)
                        })
                    }
                }
                
                NavigationLink(
                    destination: ExtendedSubtitlesView(currentSubtitle:
                                                        .init(get: { currentSubtitle }, set: didSelectSubtitle(_:)),
                                                       subtitles: subtitles),
                    isActive: $showExtendedSubtitles,
                    label: { EmptyView() })
                    .hidden()
//                    .buttonStyle(PlainNavigationLinkButtonStyle())
            }
        }
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
    
    var encodingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(text: "Encoding")
            ScrollViewReader { scroll in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(encodingsKeys, id: \.self) { key in
                            button(text: key, isSelected: currentEncoding == encodings[key]) {
                                self.currentEncoding = encodings[key]!
                                self.triggerRefresh.toggle()
                            }
                            .id(encodings[key])
                        }
                    }
                }
                .onAppear(perform: {
                    scroll.scrollTo(currentEncoding, anchor: .center)
                })
            }
            
//            ScrollViewReader { scroll in
//                List {
//                    ForEach(encodingsKeys, id: \.self) { key in
//                        button(text: key, isSelected: currentEncoding == encodings[key]) {
//                            self.currentEncoding = encodings[key]!
//                            self.triggerRefresh.toggle()
//                        }
//                        .id(encodings[key])
//                    }
//                }
//                .environment(\.defaultMinListRowHeight, 0)
//                .onAppear(perform: {
//                    scroll.scrollTo(currentEncoding, anchor: .center)
//                })
//            }
        }
    }
    
    func delayText(delay: Int) -> String {
        return (delay > 0 ? "+" : "") + NumberFormatter.localizedString(from: NSNumber(value: delay), number: .decimal)
    }
    
    func sectionHeader(text: String) -> some View {
        Text(text.localized.uppercased())
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.init(white: 1, opacity: 0.5))
            .padding(.leading, 100)
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
        })
        .padding([.leading, .trailing], 50)
        .buttonStyle(PlainButtonStyle(onFocus: {}))
    }
    
    func generateSubtitles() -> [Subtitle] {
        var subtitles = [currentSubtitle ?? subtitles[enLocale.localizedCapitalized]?.first ?? subtitles[subtitles.keys.first!]!.first!,
                         Subtitle(name: "", language: selectOther, link: "", ISO639: "", rating: 0.0)]//insert predetermined subtitle or english or first available whichever exists
        for unknownSubtitle in SubtitleSettings.shared.subtitlesSelectedForVideo {
            if let subtitle = unknownSubtitle as? Subtitle {
                if !subtitles.contains(subtitle){
                    subtitles.insert(subtitle, at: 0)
                }
            }
        }
        
        return subtitles
    }
    
    func didSelectSubtitle(_ subtitle: Subtitle?) {
        self.currentSubtitle = subtitle
        self.triggerRefresh.toggle()
        
        guard let subtitle = subtitle else {
            return
        }

        for i in 0..<SubtitleSettings.shared.subtitlesSelectedForVideo.count {
            if let savedSubtitle = SubtitleSettings.shared.subtitlesSelectedForVideo[i] as? Subtitle{
                if savedSubtitle.language == subtitle.language{// do we have a sub with the same language in permanent storage
                    SubtitleSettings.shared.subtitlesSelectedForVideo.replaceSubrange(i...i, with: [subtitle as Any])//replace the one we have with the latest one
                    let index = subtitlesInView.firstIndex(of: savedSubtitle)!
                    subtitlesInView[index] = subtitle
                    return
                }
            }
        }
        
        if !subtitlesInView.contains(subtitle){// does the subtitlesinview already have our sub if no enter
            for savedSubtitle in subtitlesInView{
                if subtitle.language == savedSubtitle.language{// do we have a sub with the same language
                    let index = subtitlesInView.firstIndex(of: savedSubtitle)!
                    subtitlesInView[index] = subtitle//switch out the one with the same language with our latest one
                    SubtitleSettings.shared.subtitlesSelectedForVideo.append(subtitle as Any)//add it to our permanent list
                    break
                }
                if savedSubtitle == subtitlesInView.last{//if we do not have a sub with the same language
                    subtitlesInView.insert(subtitle, at: 0) //add the latest selected
                    SubtitleSettings.shared.subtitlesSelectedForVideo.append(subtitle as Any)
                }
            }
        }else{// we have the sub in the subtitlesinview but not in permanent storage
            SubtitleSettings.shared.subtitlesSelectedForVideo.append(subtitle as Any)
        }
    }
}

struct SubtitlesView_Previews: PreviewProvider {
    static var previews: some View {
        let subtitle = Subtitle(name: "Test", language: "English", link: "", ISO639: "", rating: 0)
        Group {
            SubtitlesView(currentDelay: .constant(0),
                          currentEncoding: .constant(SubtitleSettings.encodings.values.first!),
                          currentSubtitle: .constant(nil)
            )
            
            SubtitlesView(currentDelay: .constant(0),
                          currentEncoding: .constant(SubtitleSettings.encodings.values.first!),
                          currentSubtitle: .constant(subtitle),
                          subtitles: [Locale.current.localizedString(forLanguageCode: "en")! : [subtitle]]
            )
        }.previewLayout(.sizeThatFits)
    }
}
