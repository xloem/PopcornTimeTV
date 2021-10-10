//
//  SelectTorrentQualityAction.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 24.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct SelectTorrentQualityButton<Label>: View where Label : View {
    var media: Media
    var action: (Torrent) -> Void
    @ViewBuilder var label: () -> Label
    
    struct AlertType: Identifiable {
        enum Choice {
            case noTorrentsFound, streamOnCellular
        }

        var id: Choice
    }

    
    @State var showChooseQualityActionSheet = false
    @State var alert: AlertType?
    
    var body: some View {
        return Button(action: {
            #if os(iOS)
            if UIDevice.current.hasCellularCapabilites &&
                Session.reachability.connection != .wifi && !Session.streamOnCellular {
                alert = .init(id: .streamOnCellular)
                return
            }
            #endif
            
            if media.torrents.count == 0 {
                alert = .init(id: .noTorrentsFound)
            } else if let torrent = autoSelectTorrent {
                action(torrent)
            } else {
                showChooseQualityActionSheet = true
            }
        }, label: label)
        .confirmationDialog("Choose Quality", isPresented: $showChooseQualityActionSheet, titleVisibility: .visible, actions: {
            chooseTorrentsButtons
        })
        .alert(item: $alert) { alert in
            switch alert.id {
            case .noTorrentsFound:
                return Alert(title: Text("No torrents found"),
                      message: Text("Torrents could not be found for the specified media."))
            case .streamOnCellular:
                return Alert(title: Text("Cellular Data is turned off for streaming"),
                      message: nil,
                      primaryButton: .default(Text("Turn On")) {
                        Session.streamOnCellular = true
                      },
                      secondaryButton: .cancel())
            }
            
        }
    }
    
    var autoSelectTorrent: Torrent? {
        if let quality = Session.autoSelectQuality {
            let sorted  = media.torrents.sorted(by: <)
            let torrent = quality == "Highest".localized ? sorted.last! : sorted.first!
            return torrent
        }
        
        #if os(tvOS)
        if media.torrents.count == 1 {
            return media.torrents[0]
        }
        #endif
        
        return nil
    }

    @ViewBuilder
    var chooseTorrentsButtons: some View {
        ForEach(media.torrents.sorted(by: >)) { torrent in
            Button {
                action(torrent)
            } label: {
//                Text(Image(uiImage: torrent.health.image.withRenderingMode(.alwaysOriginal)))
                Text(torrent.quality)
                + Text(" (seeds: \(torrent.seeds) - peers: \(torrent.peers))")
            }
        }
//        #if os(macOS)
//        Button("Cancel", role: .cancel) {
//            showChooseQualityActionSheet = false
//        }
//        #endif
    }
}

struct SelectTorrentQualityAction_Previews: PreviewProvider {
    static var previews: some View {
        SelectTorrentQualityButton(media: Movie.dummy(), action: { torrent in
            print("selected: ", torrent)
        }, label: {
            Text("Play")
        })
            .preferredColorScheme(.dark)
    }
}
