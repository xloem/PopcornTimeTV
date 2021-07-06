//
//  PopcornTimetvOS_SwiftUIApp.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import ObjectMapper

@main
struct PopcornTimetvOS_SwiftUIApp: App {
    @State var tosAccepted = Session.tosAccepted
    @State var media: Media?
    @State var showOpenedMedia: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if !tosAccepted {
                    TermsOfServiceView(tosAccepted: $tosAccepted)
                } else {
                    ZStack {
                        NavigationLink(
                            destination: mediaView,
                            isActive: $showOpenedMedia) {
                                EmptyView()
                        }
                        .hidden()
                        if (!showOpenedMedia) {
                            TabBarView()
                        }
                    }.onOpenURL { url in
                        openUrl(url: url)
                    }
                    
//                    PlayerView_Previews.dummyPreview
                }
            }
        }
    }
    
    @ViewBuilder
    var mediaView: some View {
        switch media {
        case let movie as Movie:
            MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie))
        case let show as Show:
            ShowDetailsView(viewModel: ShowDetailsViewModel(show: show))
        default:
            EmptyView()
        }
    }
    
    func openUrl(url: URL) {
        if url.scheme == "PopcornTimeSwiftUI" {
            guard
                let actions = url.absoluteString.removingPercentEncoding?.components(separatedBy: "PopcornTimeSwiftUI:?action=").last?.components(separatedBy: "»"),
                let type = actions.first, let json = actions.last
                else {
                    return
            }
            
            switch type {
            case "showMovie":
                self.media = Mapper<Movie>().map(JSONString: json)
                showOpenedMedia = true
            case "showShow":
                self.media = Mapper<Show>().map(JSONString: json)
                showOpenedMedia = true
            default:
                break
            }
        }
    }
}
