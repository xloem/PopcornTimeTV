//
//  PopcornTimetvOS_SwiftUIApp.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

@main
struct PopcornTime: App {
    @State var tosAccepted = Session.tosAccepted
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if !tosAccepted {
                    TermsOfServiceView(tosAccepted: $tosAccepted)
                } else {
                    TabBarView()
                    #if os(macOS)
                        .padding(.top, 15)
                    #elseif os(tvOS)
                        .modifier(TopShelfLinkOpener())
                    #endif
                }
                #if os(macOS)
                    Spacer()
                #endif
            }
            .preferredColorScheme(.dark)
            #if os(iOS)
            .accentColor(.white)
            .navigationViewStyle(StackNavigationViewStyle())
            #endif
        }
    }
}
