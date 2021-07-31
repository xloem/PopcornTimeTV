//
//  SettingsViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 31.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var clearCacheTitle = ""
    @Published var clearCacheMessage = ""
    
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
