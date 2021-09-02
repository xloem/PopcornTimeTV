//
//  ExtendedSubtitlesView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 27.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct ExtendedSubtitlesView: View {
    @Binding var currentSubtitle: Subtitle?
    @State var triggerRefresh = false
    @State var showLanguageAlert = false
    
    var subtitles = Dictionary<String, [Subtitle]>()
    
    var body: some View {
        VStack (alignment:.leading, spacing: 10) {
            Spacer()
            languageSection
            subtitlesSection
            Spacer()
        }
        .frame(width: 1140)
        .frame(maxHeight: 860)
    }
    
    let enLocale = Locale.current.localizedString(forLanguageCode: "en")!
    var displaySubtitles: [Subtitle]  {
        return subtitles[currentSubtitle?.language ?? enLocale] ?? []
    }
    
    var languageSection: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("Language".localized)
            Spacer()
            Button(action: {
                self.showLanguageAlert = true
            }, label: {
                HStack(spacing: 5) {
                    Text(currentSubtitle?.language ?? "None".localized)
                    Image(systemName: "greaterthan")
                }
            })
            .buttonStyle(PlainButtonStyle(onFocus: {}))
        }
        .font(.system(size: 38, weight: .regular))
        .foregroundColor(.init(white: 1, opacity: 0.5))
        .confirmationDialog(Text("Select Language".localized), isPresented: $showLanguageAlert, titleVisibility: .visible, actions: {
            languageButtons
            Button("Cancel", role: .cancel, action: {})
        })
        .padding()
    }
    
    @ViewBuilder
    var languageButtons: some View {
        let items = Array(subtitles.keys).sorted()
        ForEach(items, id: \.self) { language in
            Button {
                self.currentSubtitle = self.subtitles[language]?.first
            } label: { Text(language) }

        }
    }
    
    var subtitlesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                sectionHeader(text: "Available Subtitles")
                Spacer()
            }
            ScrollViewReader { scroll in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(displaySubtitles) { subtitle in
                            button(subtitle: subtitle, isSelected: subtitle.name == currentSubtitle?.name) {
                                self.currentSubtitle = currentSubtitle == subtitle ? nil : subtitle
                                self.triggerRefresh.toggle()
                            }
                            .id(subtitle.language)
                        }
                    }
                }
                .onAppear(perform: {
                    scroll.scrollTo(currentSubtitle?.language, anchor: .center)
                })
            }
        }
    }
    
    func sectionHeader(text: String) -> some View {
        Text(text.localized)
            .font(.system(size: 38, weight: .regular))
            .foregroundColor(.init(white: 1, opacity: 0.5))
            .padding()
    }
    
    func button(subtitle: Subtitle, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            HStack(spacing: 20) {
                if (isSelected) {
                    Image(systemName: "checkmark")
                } else {
                    Text("").frame(width: 32)
                }
//                VStack(alignment: .leading) {
                    Text(subtitle.name)
                        .font(.system(size: 32, weight: .regular))
                    Spacer()
//                    Text(subtitle.language)
//                        .font(.system(size: 32, weight: .regular))
//                }
                
            }
            .padding([.leading, .trailing], 50) // allow space for scale animation
        })
        .buttonStyle(PlainButtonStyle(onFocus: {}))
    }
    
    func generateSubtitles() -> [Subtitle] {
        var subtitles = [currentSubtitle ?? subtitles[enLocale.localizedCapitalized]?.first ?? subtitles[subtitles.keys.first!]!.first!,
                         Subtitle(name: "", language: "Select Other".localized, link: "", ISO639: "", rating: 0.0)]//insert predetermined subtitle or english or first available whichever exists
        
        for unknownSubtitle in SubtitleSettings.shared.subtitlesSelectedForVideo {
            if let subtitle = unknownSubtitle as? Subtitle {
                if !subtitles.contains(subtitle){
                    subtitles.insert(subtitle, at: 0)
                }
            }
        }
        
        return subtitles
    }
}

struct ExtendedSubtitlesView_Previews: PreviewProvider {
    static var previews: some View {
        let subtitle = Subtitle(name: "Test", language: "English", link: "", ISO639: "", rating: 0)
        Group {
            ExtendedSubtitlesView(
                currentSubtitle: .constant(subtitle),
                subtitles: [Locale.current.localizedString(forLanguageCode: "en")! : [subtitle]]
            )
        }.previewLayout(.sizeThatFits)
    }
}
