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
                .environmentObject(MoviesViewModel())
                .tabItem {
                    Text("Movies")
                }
            ShowsView()
                .tabItem {
                    Text("Shows")
                }
            WatchlistView()
                .tabItem {
                    Text("Watchlist")
                }
            SearchView()
                .tabItem {
                    Text("🔍")
                }
            DownloadView()
                .tabItem {
                    Text("Downloads")
                }
            SettingsView()
                .tabItem {
                    Text("Settings")
                }
            
        }.ignoresSafeArea()
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
