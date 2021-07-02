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
    @State var tosAccepted = Session.tosAccepted
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if !tosAccepted {
                    TermsOfServiceView(tosAccepted: $tosAccepted)
                } else {
                    TabBarView()
//                    PlayerView_Previews.dummyPreview
                }
            }
        }
    }
}
