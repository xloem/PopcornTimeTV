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
struct PopcornTime: App {
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
                        #if os(tvOS)
                        NavigationLink(
                            destination: mediaView,
                            isActive: $showOpenedMedia) {
                                EmptyView()
                        }
                        .hidden()
                        #endif
                        
                        TabBarView()
                        #if os(macOS)
                            .padding(.top, 15)
                        #endif
                    }.onOpenURL { url in
                        openUrl(url: url)
                    }
                    
//                    PlayerView_Previews.dummyPreview
                }
                #if os(macOS)
                    Spacer()
                #endif
            }
            .preferredColorScheme(.dark)
            #if os(iOS)
            .accentColor(.white)
//            .navigationViewStyle(StackNavigationViewStyle())
            #endif
        }
    }
    
    #if os(tvOS)
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
    #endif
    
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
