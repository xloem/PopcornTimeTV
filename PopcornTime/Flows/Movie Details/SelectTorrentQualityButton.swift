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
    
    @State var showChooseQualityActionSheet = false
    @State var noTorrentsFoundAlert = false
    @State var showStreamOnCellularAlert = false
    var onFocus: () -> Void = {}
    
    var body: some View {
        return Button(action: {
            #if os(iOS)
            if UIDevice.current.hasCellularCapabilites &&
                Session.reachability.connection != .wifi && !Session.streamOnCellular {
                self.showStreamOnCellularAlert = true
                return
            }
            #endif
            
            if media.torrents.count == 0 {
                self.noTorrentsFoundAlert = true
            } else if let torrent = autoSelectTorrent {
                action(torrent)
            } else {
                showChooseQualityActionSheet = true
            }
        }, label: label)
        .buttonStyle(TVButtonStyle(onFocus: onFocus))
        .confirmationDialog("Choose Quality", isPresented: $showChooseQualityActionSheet, titleVisibility: .visible, actions: {
            chooseTorrentsButtons
        })
        .alert(isPresented: $noTorrentsFoundAlert, content: {
            Alert(title: Text("No torrents found".localized),
                  message: Text("Torrents could not be found for the specified media.".localized),
                  dismissButton: .cancel())
        }).alert(isPresented: $showStreamOnCellularAlert, content: {
            Alert(title: Text("Cellular Data is turned off for streaming".localized),
                  message: nil,
                  primaryButton: .default(Text("Turn On".localized)) {
                    Session.streamOnCellular = true
                  },
                  secondaryButton: .cancel())
        })
    }
    
    var autoSelectTorrent: Torrent? {
        if let quality = Session.autoSelectQuality {
            let sorted  = media.torrents.sorted(by: <)
            let torrent = quality == "Highest".localized ? sorted.last! : sorted.first!
            return torrent
        }
        
        if media.torrents.count == 1 {
            return media.torrents[0]
        }
        
        return nil
    }

    @ViewBuilder
    var chooseTorrentsButtons: some View {
        ForEach(media.torrents) { torrent in
            Button {
                action(torrent)
            } label: {
//                Text(Image(uiImage: torrent.health.image.withRenderingMode(.alwaysOriginal)))
                Text(torrent.quality)
                + Text(" (seeds: \(torrent.seeds) - peers: \(torrent.peers))")
            }
        }
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
