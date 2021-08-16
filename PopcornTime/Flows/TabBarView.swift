//
//  TabBarView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            MoviesView()
                .tabItem {
                    Image("Movies On").renderingMode(.template)
                    Text("Movies")
                }
            ShowsView()
                .tabItem {
                    Image("Shows On").renderingMode(.template)
                    Text("Shows")
                }
            WatchlistView()
                .tabItem {
                    Image("Watchlist On").renderingMode(.template)
                    Text("Watchlist")
                }
            #if os(tvOS)
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
            #endif
            DownloadsView()
                .tabItem {
                    Image(systemName: "square.and.arrow.down")
                    Text("Downloads")
                }
            #if os(tvOS) || os(iOS)
            SettingsView()
                .tabItem {
                    Image("Settings On").renderingMode(.template)
                    Text("Settings")
                }
            #endif
            
        }.ignoresSafeArea()
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
