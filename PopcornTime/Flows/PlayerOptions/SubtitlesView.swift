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
    @StateObject var viewModel: SubtitlesViewModel
    @State var showExtendedSubtitles = false
    @State var triggerRefresh = false
    
    var body: some View {
        HStack (alignment:.top, spacing: 0) {
            if !showExtendedSubtitles {
                Spacer()
                languageSection
                    .frame(width: 390)
                delaySection
                encodingSection
                Spacer()
            } else {
                let binding: Binding<Subtitle?> = Binding.init(get: {
                    currentSubtitle
                }, set: { item in
                    currentSubtitle = item
                    viewModel.didSelectSubtitle(item)
                    triggerRefresh.toggle()
                })
                
                ExtendedSubtitlesView(currentSubtitle: binding,
                                      subtitles: viewModel.subtitles,
                                      isPresented: $showExtendedSubtitles)
                    .padding(.horizontal, 10)
            }
        }
        #if os(tvOS)
        .focusSection()
        #endif
    }
    
    var languageSection: some View {
        Group {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(text: "Language")
                if viewModel.subtitles.isEmpty {
                    Text("No subtitles available.".localized)
                        .foregroundColor(.init(white: 1, opacity: 0.5))
                        .font(.system(size: 35, weight: .medium))
                        .padding(.leading, 20)
                } else {
                    ScrollViewReader { scroll in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 15) {
                                ForEach(viewModel.subtitlesInView) { subtitle in
                                    button(text: subtitle.language, isSelected: subtitle.language == currentSubtitle?.language, onFocus: {
                                        scroll.scrollTo(subtitle.language, anchor: .center)
                                    }) {
                                        if subtitle.language == viewModel.selectOther {
                                            self.showExtendedSubtitles = true
                                        } else {
                                            currentSubtitle = currentSubtitle == subtitle ? nil : subtitle
                                            triggerRefresh.toggle()
                                        }
                                    }
                                    .id(subtitle.language)
                                }
                            }
                        }
                        .onAppear(perform: {
                            viewModel.subtitlesInView = viewModel.generateSubtitles(currentSubtitle: currentSubtitle)
                            scroll.scrollTo(currentSubtitle?.language, anchor: .center)
                        })
                    }
                }
            }
        }
        #if os(tvOS)
        .focusSection()
        #endif
    }
    
    @ViewBuilder
    var delaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(text: "Delay")
            ScrollViewReader { scroll in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        ForEach(viewModel.delays) { delay in
                            button(text: viewModel.delayText(delay: delay), isSelected: delay == currentDelay, onFocus: {
                                withAnimation {
                                    scroll.scrollTo(delay, anchor: .center)
                                }
                            }) {
                                currentDelay = delay
                                triggerRefresh.toggle()
                            }
                            .id(delay)
//                            .prefersDefaultFocus(delay == currentDelay, in: delayNamespace)
                        }
                    }
                }
                .onAppear(perform: {
                    scroll.scrollTo(currentDelay, anchor: .center)
                })
            }
        }
        #if os(tvOS)
        .focusSection()
        #endif
//        .focusScope(delayNamespace)
    }
    
    @ViewBuilder
    var encodingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(text: "Encoding")
            ScrollViewReader { scroll in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        ForEach(viewModel.encodingsKeys, id: \.self) { key in
                            let item = viewModel.encodings[key]
                            
                            button(text: key, isSelected: currentEncoding == item, onFocus: {
                                withAnimation {
                                    scroll.scrollTo(item, anchor: .center)
                                }
                            }) {
                                currentEncoding = item!
                                triggerRefresh.toggle()
                            }
                            .id(item)
//                            .prefersDefaultFocus(encodings[key] == currentEncoding, in: encodingNamespace)
                        }
                    }
                }
                .onAppear(perform: {
                    scroll.scrollTo(currentEncoding, anchor: .center)
                })
            }
            #if os(tvOS)
            .focusSection()
            #endif
            
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
//        .focusScope(encodingNamespace)
    }
    
    func sectionHeader(text: String) -> some View {
        Text(text.localized.uppercased())
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.init(white: 1, opacity: 0.5))
            .padding(.leading, 100)
    }
    
    func button(text: String, isSelected: Bool, onFocus: @escaping () -> Void, action: @escaping () -> Void) -> some View {
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
        .buttonStyle(PlainButtonStyle(onFocus: onFocus))
    }
}

struct SubtitlesView_Previews: PreviewProvider {
    static var previews: some View {
        let subtitle = Subtitle(name: "Test", language: "English", link: "", ISO639: "", rating: 0)
        let encoding = SubtitleSettings.encodings.values.first!
        let enKey: String = Locale.current.localizedString(forLanguageCode: "en") ?? ""
        let subtitles: Dictionary<String, [Subtitle]> = [enKey : [subtitle]]

        Group {
            SubtitlesView(currentDelay: .constant(0),
                          currentEncoding: .constant(encoding),
                          currentSubtitle: .constant(nil),
                          viewModel:SubtitlesViewModel()
            )
            
            SubtitlesView(currentDelay: .constant(0),
                          currentEncoding: .constant(encoding),
                          currentSubtitle: .constant(subtitle),
                        viewModel: SubtitlesViewModel(subtitles: subtitles)
            )
            
            SubtitlesView(currentDelay: .constant(0),
                          currentEncoding: .constant(encoding),
                          currentSubtitle: .constant(subtitle),
                          viewModel:SubtitlesViewModel(subtitles: subtitles),
                showExtendedSubtitles: true
            )
        }
        .frame(maxHeight: 300)
        .previewLayout(.sizeThatFits)
    }
}
