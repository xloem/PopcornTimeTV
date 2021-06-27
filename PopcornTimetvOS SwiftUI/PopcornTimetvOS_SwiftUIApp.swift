//
//  PopcornTimetvOS_SwiftUIApp.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

@main
struct PopcornTimetvOS_SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if !Session.tosAccepted {
                    TermsOfServiceView()
                } else {
                    TabBarView()
                }
            }.onAppear {
                let adjustedVolume = UserDefaults.standard.float(forKey: "themeSongVolume") * 0.25
                if adjustedVolume == 0 {
                    UserDefaults.standard.set(0.75, forKey: "themeSongVolume")
                }
            }
        }
    }
}
