//
//  PlayButton.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 21.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import Combine

struct PlayButton: View {
    var viewModel: DetailViewModel
    @State var preloadTorrentModel: PreloadTorrentViewModel?
    @State var playerModel: PlayerViewModel?
    @State var listenForReadToPlay: AnyCancellable?
    
    @State var showChooseQualityAction: Bool = false
    @State var noTorrentsFoundAlert: Bool = false
    @State var showStreamOnCellularAlert = false
    @State var torrent: Torrent?
    
    @State var selection: Selection? = nil
    enum Selection: Int, Identifiable {
        case preload = 2
        case play = 3
        
        var id: Int { return rawValue }
    }
    var movie: Movie {
        return viewModel.movie
    }
    
    var body: some View {
        Group {
            if let _ = torrent {
                switch selection {
                case .some(.preload):
                    NavigationLink(
                        destination: PreloadTorrentView(viewModel: preloadTorrentModel!),
                        tag: Selection.preload,
                        selection: $selection) {
                            EmptyView()
                    }
                case .some(.play):
                    NavigationLink(
                        destination: PlayerView().environmentObject(playerModel!),
                        tag: Selection.play,
                        selection: $selection) {
                            EmptyView()
                        }
                case nil: EmptyView()
                }
            }
            Button(action: {
                if movie.torrents.count == 0 {
                    self.noTorrentsFoundAlert = true
                } else if let torrent = viewModel.autoSelectTorrent {
                    playTorrent(torrent)
                } else {
                    showChooseQualityAction = true
                }
            }, label: {
                VStack {
                    VisualEffectBlur() {
                        Image("Play")
                    }
                    Text("Play".localized)
                }
            })
            .frame(width: 142, height: 115)
            .actionSheet(isPresented: $showChooseQualityAction) {
                ActionSheet(title: Text("Choose Quality".localized),
                            message: nil,
                            buttons: chooseTorrentsButtons + [.cancel()]
                )
            }
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
    }
    
    var chooseTorrentsButtons: [Alert.Button] {
        movie.torrents.map { torrent in
            ActionSheet.Button.default(
                Text(Image(uiImage: torrent.health.image.withRenderingMode(.alwaysOriginal))) +
                Text(torrent.quality)) {
                playTorrent(torrent)
            }
        }
    }
    
    func playTorrent(_ torrent: Torrent) {
        if UIDevice.current.hasCellularCapabilites && !Session.reachability.isReachableViaWiFi() && !Session.streamOnCellular {
            self.showStreamOnCellularAlert = true
        } else {
            self.torrent = torrent
            self.preloadTorrentModel = PreloadTorrentViewModel(torrent: torrent, media: movie)
            self.listenForReadToPlay = self.preloadTorrentModel?.objectWillChange.sink(receiveValue: { _ in
                if let playerModel = self.preloadTorrentModel?.playerModel {
                    self.playerModel = playerModel
                    selection = Selection.play
                }
            })
            selection = Selection.preload
        }
    }
}

struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayButton(viewModel: DetailViewModel(movie: Movie.dummy()))
            .buttonStyle(TVButtonStyle())
            .padding(40)
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
