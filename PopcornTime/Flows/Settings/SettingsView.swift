//
//  SettingsView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct SettingsView: View {
    struct Theme {
        let fontSize: CGFloat = value(tvOS: 38, macOS: 20)
        let hStackSpacing: CGFloat = value(tvOS: 300, macOS: 50)
        let iconLeading: CGFloat = value(tvOS: 100, macOS: 50)
    }
    let theme = Theme()
    
    let subtitleSettings = SubtitleSettings.shared
    @StateObject var viewModel = SettingsViewModel()
    
    @State var showSongVolumeAlert = false
    @State var showQualityAlert = false
    
    @State var showSubtitleLanguageAlert = false
    @State var showSubtitleFontSizeAlert = false
    @State var showSubtitleFontColorAlert = false
    @State var showSubtitleFontAlert = false
    @State var showSubtitleFontStyleAlert = false
    @State var showSubtitleEncondingAlert = false
    
    @State var showTraktAlert = false
    
    @State var showClearCacheAlert = false
    
    
    var body: some View {
        HStack (spacing: theme.hStackSpacing) {
            #if os(tvOS) || os(iOS)
            Image("Icon")
                .padding(.leading, theme.iconLeading)
            #endif
            List() {
                Section(header: sectionHeader("Player")) {
                    themeSongVolumeButton
                    removeCacheOnPlayerExitButton
                    qualityAlertButton
                }
                
                Section(header: sectionHeader("Subtitles")) {
                    subtitleLanguageButton
                    subtitleFontSizeButton
                    subtitleFontColorButton
                    subtitleFontButton
                    subtitleFontStyleButton
                    subtitleEncondingButton
                }
                
//                Section(header: sectionHeader("Services")) {
//                    trackButton
//                }
                
                Section(header: Text("Info".localized.uppercased())) {
                    clearCacheButton
//                    button(text: "Check for Updates", value: lastUpdate) {
//
//                    }
                    button(text: "Version", value: viewModel.version) {
                        
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .padding(.trailing, theme.iconLeading)
        }
//        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    var themeSongVolumeButton: some View {
        let volume = NumberFormatter.localizedString(from: NSNumber(value: Session.themeSongVolume), number: .percent)
        button(text: "Theme Song Volume", value: volume) {
            showSongVolumeAlert = true
        }.actionSheet(isPresented: $showSongVolumeAlert) {
            songVolumeAlert
        }
    }
    
    var songVolumeAlert: ActionSheet {
        let actions = [0.25, 0.5, 0.75, 1].map ({ percentage -> Alert.Button in
            let value = NumberFormatter.localizedString(from: NSNumber(value: percentage), number: .percent)
            return Alert.Button.default(Text(value)) {
                Session.themeSongVolume = Float(percentage)
            }
        })
        
        return ActionSheet(title: Text("Theme Song Volume".localized),
                    message: Text("Choose a volume for the TV Show and Movie theme songs.".localized),
                    buttons:[
                        .cancel(),
                        .default(Text("Off".localized), action: {
                            Session.themeSongVolume = 0
                        })
                    ] + actions
        )
    }
    
    @State var clearCacheText = Session.removeCacheOnPlayerExit ? "On".localized : "Off".localized
    @ViewBuilder
    var removeCacheOnPlayerExitButton: some View {
        button(text: "Clear Cache Upon Exit", value: clearCacheText) {
            Session.removeCacheOnPlayerExit.toggle()
            clearCacheText = Session.removeCacheOnPlayerExit ? "On".localized : "Off".localized
        }
    }
    
    @ViewBuilder
    var qualityAlertButton: some View {
        button(text: "Auto Select Quality", value: Session.autoSelectQuality?.localized ?? "Off".localized) {
            showQualityAlert = true
        }
        .actionSheet(isPresented: $showQualityAlert) {
            qualityAlert
        }
    }
    
    var qualityAlert: ActionSheet {
        let actions = ["Off", "Highest", "Lowest"].map ({ quality -> Alert.Button in
            return Alert.Button.default(Text(quality.localized)) {
                Session.autoSelectQuality = quality == "Off" ? nil : quality
            }
        })
        
        return ActionSheet(title: Text("Auto Select Quality".localized),
                    message: Text("Choose a default quality. If said quality is available, it will be automatically selected.".localized),
                    buttons:[
                        .cancel(),
                    ] + actions
        )
    }
    
    
    @ViewBuilder
    var subtitleLanguageButton: some View {
        button(text: "Language", value: subtitleSettings.language ?? "None".localized) {
            showSubtitleLanguageAlert = true
        }
        .actionSheet(isPresented: $showSubtitleLanguageAlert) {
            subtitleLanguageAlert
        }
    }
    
    var subtitleLanguageAlert: ActionSheet {
        let values = ["None"] + Locale.commonLanguages
        let actions = values.map ({ language -> Alert.Button in
            return Alert.Button.default(Text(language.localized)) {
                subtitleSettings.language = language == "None".localized ? nil : language
                subtitleSettings.save()
            }
        })
        
        return ActionSheet(title: Text("Auto Select Quality".localized),
                    message: Text("Choose a default quality. If said quality is available, it will be automatically selected.".localized),
                    buttons:[
                        .cancel(),
                    ] + actions
        )
    }
    
    @ViewBuilder
    var subtitleFontSizeButton: some View {
        button(text: "Size", value: subtitleSettings.size.localizedString) {
            showSubtitleFontSizeAlert = true
        }
        .actionSheet(isPresented: $showSubtitleFontSizeAlert) {
            subtitleFontSizeAlert
        }
    }
    
    var subtitleFontSizeAlert: ActionSheet {
        let values = SubtitleSettings.Size.allCases
        let actions = values.map ({ size -> Alert.Button in
            return Alert.Button.default(Text(size.localizedString)) {
                subtitleSettings.size = size
                subtitleSettings.save()
            }
        })
        
        return ActionSheet(title: Text("Subtitle Font Size".localized),
                    message: Text("Choose a font size for the player subtitles.".localized),
                    buttons:[
                        .cancel(),
                    ] + actions
        )
    }
    
    @ViewBuilder
    var subtitleFontColorButton: some View {
        let colorValue = UIColor.systemColors.first(where: {$0 == subtitleSettings.color})?.localizedString ?? ""
        button(text: "Color", value: colorValue) {
            showSubtitleFontColorAlert = true
        }
        .actionSheet(isPresented: $showSubtitleFontColorAlert) {
            subtitleFontColorAlert
        }
    }
    
    var subtitleFontColorAlert: ActionSheet {
        let values = UIColor.systemColors
        let actions = values.map ({ color -> Alert.Button in
            return Alert.Button.default(Text(color.localizedString!)) {
                subtitleSettings.color = color
                subtitleSettings.save()
            }
        })
        
        return ActionSheet(title: Text("Subtitle Color".localized),
                    message: Text("Choose text color for the player subtitles.".localized),
                    buttons:[
                        .cancel(),
                    ] + actions
        )
    }
    
    
    @ViewBuilder
    var subtitleFontButton: some View {
        button(text: "Font", value: subtitleSettings.font.familyName) {
            showSubtitleFontAlert = true
        }
        .actionSheet(isPresented: $showSubtitleFontAlert) {
            subtitleFontAlert
        }
    }
    
    var subtitleFontAlert: ActionSheet {
        let values = UIFont.familyNames
        let actions = values.map ({ fontFamily -> Alert.Button in
            return Alert.Button.default(Text(fontFamily)) {
                guard let fontName = UIFont.fontNames(forFamilyName: fontFamily).first,
                let font = UIFont(name: fontName, size: 16) else {
                    return
                }
                subtitleSettings.font = font
                subtitleSettings.save()
            }
        })
        
        return ActionSheet(title: Text("Subtitle Font".localized),
                    message: Text("Choose a default font for the player subtitles.".localized),
                    buttons:[
                        .cancel(),
                    ] + actions
        )
    }
    
    @ViewBuilder
    var subtitleFontStyleButton: some View {
        button(text: "Style", value: subtitleSettings.style.localizedString) {
            showSubtitleFontStyleAlert = true
        }
        .actionSheet(isPresented: $showSubtitleFontStyleAlert) {
            subtitleFontStyleAlert
        }
    }
    
    var subtitleFontStyleAlert: ActionSheet {
        let values = FontStyle.arrayValue
        let actions = values.map ({ style -> Alert.Button in
            return Alert.Button.default(Text(style.localizedString)) {
                subtitleSettings.style = style
                subtitleSettings.save()
            }
        })
        
        return ActionSheet(title: Text("Subtitle Font Style".localized),
                    message: Text("Choose a default font style for the player subtitles.".localized),
                    buttons:[
                        .cancel(),
                    ] + actions
        )
    }
    
    @ViewBuilder
    var subtitleEncondingButton: some View {
        button(text: "Encoding", value: subtitleSettings.encoding) {
            showSubtitleEncondingAlert = true
        }
        .actionSheet(isPresented: $showSubtitleEncondingAlert) {
            subtitleEncondingAlert
        }
    }
    
    var subtitleEncondingAlert: ActionSheet {
        let subtitleSettings = SubtitleSettings.shared
        let values = SubtitleSettings.encodings.sorted(by: { $0.0 < $1.0 })
        
        let actions = values.map ({ (title, value) -> Alert.Button in
            return Alert.Button.default(Text(title.localized)) {
                subtitleSettings.encoding = value
                subtitleSettings.save()
            }
        })
        
        return ActionSheet(title: Text("Subtitle Encoding".localized),
                    message: Text("Choose encoding for the player subtitles.".localized),
                    buttons:[
                        .cancel(),
                    ] + actions
        )
    }
    
    @ViewBuilder
    var clearCacheButton: some View {
        button(text: "Clear All Cache", value: "") {
            viewModel.clearCache()
            showClearCacheAlert = true
        }
        .actionSheet(isPresented: $showClearCacheAlert) {
            clearCacheAlert
        }
    }
    
    var clearCacheAlert: ActionSheet {
        return ActionSheet(title: Text(viewModel.clearCacheTitle),
                           message: Text(viewModel.clearCacheMessage),
                    buttons:[
                        .default(Text("Ok".localized), action: {
                        }),
                    ]
        )
    }
    


    @ViewBuilder
    var trackButton: some View {
        let tracktValue = TraktManager.shared.isSignedIn() ? "Sign Out".localized : "Sign In".localized
        button(text: "Trakt", value: tracktValue) {
            if TraktManager.shared.isSignedIn() {
                showTraktAlert = true
            } else  {
//                TraktManager.shared.delegate = self
//                let vc = TraktManager.shared.loginViewController()
//                present(vc, animated: true)
            }
        }
        .actionSheet(isPresented: $showTraktAlert) {
            traktAlert
        }
    }

    var traktAlert: ActionSheet {
        return ActionSheet(title: Text("Sign Out".localized),
                    message: Text("Are you sure you want to Sign Out?".localized),
                    buttons:[
                        .default(Text("Sign Out".localized), action: {
                            do {
                                try TraktManager.shared.logout()
                            } catch { }
                        }),
                        .cancel(),
                    ]
        )
    }
    
    
    func button(text: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            HStack {
                Text(text.localized)
                Spacer()
                Text(value)
                    .multilineTextAlignment(.trailing)
            }
            .font(.system(size: theme.fontSize, weight: .medium))
        })
    }
    
    func sectionHeader(_ text: String) -> some View {
        return Text(text.localized.uppercased())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
