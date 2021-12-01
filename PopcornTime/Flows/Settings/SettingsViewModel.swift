//
//  SettingsViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 31.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

class SettingsViewModel: ObservableObject {
    @Published var clearCache = ClearCache()
    
    @Published var isTraktSingedIn: Bool = TraktManager.shared.isSignedIn()
    var traktAuthorizationUrl: URL = TraktManager.shared.authorizationUrl(appScheme: AppScheme)
    
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
    
    func validate(traktUrl: URL) {
        if traktUrl.scheme?.lowercased() == AppScheme.lowercased() {
            TraktManager.shared.authenticate(traktUrl) { error in
                let success = error == nil
                if success {
                    self.traktDidLoggedIn()
                }
            }
        }
    }
    
    func traktLogout() {
        TraktManager.shared.logout()
        isTraktSingedIn = false
    }
    
    func traktDidLoggedIn() {
        isTraktSingedIn = true
        TraktManager.shared.syncUserData()
    }
}
