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
    @State var showSongVolumeAlert = false
    @State var showQualityAlert = false
    
    @State var showSubtitleLanguageAlert = false
    @State var showSubtitleFontSizeAlert = false
    @State var showSubtitleFontColorAlert = false
    @State var showSubtitleFontAlert = false
    @State var showSubtitleFontStyleAlert = false
    @State var showSubtitleEncondingAlert = false
    
    @State var showTraktAlert = false
    @State var triggerUIRefresh = false
    
    @State var showClearCacheAlert = false
    
    
    var body: some View {
        HStack (spacing: 300) {
            Image("Icon")
                .padding(.leading, 100)
            List() {
                Section(header: sectionHeader("Player")) {
                    let volume = NumberFormatter.localizedString(from: NSNumber(value: Session.themeSongVolume), number: .percent)
                    button(text: "Theme Song Volume", value: volume) {
                        showSongVolumeAlert = true
                    }
                    
                    let clearCache = Session.removeCacheOnPlayerExit ? "On".localized : "Off".localized
                    button(text: "Clear Cache Upon Exit", value: clearCache) {
                        Session.removeCacheOnPlayerExit.toggle()
                        triggerUIRefresh.toggle()
                    }
                    button(text: "Auto Select Quality", value: Session.autoSelectQuality?.localized ?? "Off".localized) {
                        showQualityAlert = true
                    }
                }
                
                let subtitleSettings = SubtitleSettings.shared
                Section(header: sectionHeader("Subtitles")) {
                    button(text: "Language", value: subtitleSettings.language ?? "None".localized) {
                        showSubtitleLanguageAlert = true
                    }
                    button(text: "Size", value: subtitleSettings.size.localizedString) {
                        showSubtitleFontSizeAlert = true
                    }
                    let colorValue = UIColor.systemColors.first(where: {$0 == subtitleSettings.color})?.localizedString ?? ""
                    button(text: "Color", value: colorValue) {
                        showSubtitleFontColorAlert = true
                    }
                    button(text: "Font", value: subtitleSettings.font.familyName) {
                        showSubtitleFontAlert = true
                    }
                    button(text: "Style", value: subtitleSettings.style.localizedString) {
                        showSubtitleFontStyleAlert = true
                    }
                    button(text: "Encoding", value: subtitleSettings.encoding) {
                        showSubtitleEncondingAlert = true
                    }
                }
                
//                Section(header: sectionHeader("Services")) {
//                    let tracktValue = TraktManager.shared.isSignedIn() ? "Sign Out".localized : "Sign In".localized
//                    button(text: "Trakt", value: tracktValue) {
//                        if TraktManager.shared.isSignedIn() {
//                            showTraktAlert = true
//                        } else  {
////                            TraktManager.shared.delegate = self
////                            let vc = TraktManager.shared.loginViewController()
////                            present(vc, animated: true)
//                        }
//                    }
//                }
                
                Section(header: Text("Info".localized.uppercased())) {
                    button(text: "Clear All Cache", value: "") {
                        clearCache()
                        showClearCacheAlert = true
                    }
//                    button(text: "Check for Updates", value: lastUpdate) {
//
//                    }
                    button(text: "Version", value: version) {
                        
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .actionSheet(isPresented: $showSongVolumeAlert) {
                songVolumeAlert
            }
            .actionSheet(isPresented: $showQualityAlert) {
                qualityAlert
            }
            .actionSheet(isPresented: $showSubtitleLanguageAlert) {
                subtitleLanguageAlert
            }
            .actionSheet(isPresented: $showSubtitleFontSizeAlert) {
                subtitleFontSizeAlert
            }
            .actionSheet(isPresented: $showSubtitleFontColorAlert) {
                subtitleFontColorAlert
            }
            .actionSheet(isPresented: $showSubtitleFontStyleAlert) {
                subtitleFontStyleAlert
            }
            .actionSheet(isPresented: $showSubtitleEncondingAlert) {
                subtitleEncondingAlert
            }
            .actionSheet(isPresented: $showTraktAlert) {
                traktAlert
            }
            .actionSheet(isPresented: $showClearCacheAlert) {
                clearCacheAlert
            }
        }
    }
    
    func clearCache() {
        do {
            let size = FileManager.default.folderSize(atPath: NSTemporaryDirectory())
            for path in try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory()) {
                try FileManager.default.removeItem(atPath: NSTemporaryDirectory() + "/\(path)")
            }
            clearCacheTitle = "Success".localized
            if size == 0 {
                clearCacheMessage = "Cache was already empty, no disk space was reclaimed.".localized
            } else {
                clearCacheMessage = "Cleaned".localized + " \(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))."
            }
        } catch {
            clearCacheTitle = "Failed".localized
            clearCacheMessage = "Error cleaning cache.".localized
        }
    }
    @State var clearCacheTitle = ""
    @State var clearCacheMessage = ""
    
    var clearCacheAlert: ActionSheet {
        return ActionSheet(title: Text(clearCacheTitle),
                    message: Text(clearCacheMessage),
                    buttons:[
                        .default(Text("Ok".localized), action: {
                        }),
                    ]
        )
    }

    var traktAlert: ActionSheet {
        return ActionSheet(title: Text("Sign Out".localized),
                    message: Text("Are you sure you want to Sign Out?".localized),
                    buttons:[
                        .default(Text("Sign Out".localized), action: {
                            do {
                                try TraktManager.shared.logout()
                            } catch { }
                            triggerUIRefresh.toggle()
                        }),
                        .cancel(),
                    ]
        )
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
    
    var subtitleFontStyleAlert: ActionSheet {
        let subtitleSettings = SubtitleSettings.shared
        let values = UIFont.Style.arrayValue
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
    
    var subtitleFontAlert: ActionSheet {
        let subtitleSettings = SubtitleSettings.shared
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
    
    var subtitleFontColorAlert: ActionSheet {
        let subtitleSettings = SubtitleSettings.shared
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
    
    var subtitleFontSizeAlert: ActionSheet {
        let subtitleSettings = SubtitleSettings.shared
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
    
    var subtitleLanguageAlert: ActionSheet {
        let subtitleSettings = SubtitleSettings.shared
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
            .font(.system(size: 38, weight: .medium))
        })
    }
    
    func sectionHeader(_ text: String) -> some View {
        return Text(text.localized.uppercased())
    }
    
    var lastUpdate: String {
        var date = "Never".localized
        if let lastChecked = Session.lastVersionCheckPerformedOnDate {
            date = DateFormatter.localizedString(from: lastChecked, dateStyle: .short, timeStyle: .short)
        }
        return date
    }
    
    var version: String {
        let bundle = Bundle.main
        return [bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString"), bundle.object(forInfoDictionaryKey: "CFBundleVersion")].compactMap({$0 as? String}).joined(separator: ".")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
