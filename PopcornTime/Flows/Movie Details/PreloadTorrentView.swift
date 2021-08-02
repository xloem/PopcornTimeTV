//
//  PreloadTorrentView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import Kingfisher

struct PreloadTorrentView: View {
    @StateObject var viewModel: PreloadTorrentViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text(viewModel.media.title)
                    .font(.title3)
                    .padding(.bottom, 20)
                if viewModel.isProcessing {
                    ProgressView()
                } else {
                    VStack {
                        ProgressView(value: $viewModel.progress.wrappedValue)
                        Text(ByteCountFormatter.string(fromByteCount: Int64(viewModel.speed), countStyle: .binary) + "/s")
                        Text("\(viewModel.seeds) " + "Seeds".localized.localizedLowercase)
                    }
                    .font(.system(size: 30, weight: .medium))
                    .frame(width: 600)
                }
                Spacer()
            }.onAppear {
                viewModel.playTorrent()
            }.onDisappear {
                viewModel.cancel()
            }
            .alert(isPresented: $viewModel.showError, content: {
                Alert(title: Text("Error".localized),
                      message: Text(viewModel.error?.localizedDescription ?? ""),
                      dismissButton: .cancel(Text("Cancel".localized), action: {
                        presentationMode.wrappedValue.dismiss()
                      }))
            })
//            .actionSheet(isPresented: $viewModel.showFileToPlay) {
//                ActionSheet(title: Text("Select file to play".localized),
//                            message: nil,
//                            buttons: chooseTorrentsButtons + [.cancel()]
//                )
//            }
        }
    }
    
//    var chooseFileButtons: [Alert.Button] {
//        return viewModel.torrents
//        for torrent in torrents{
//            torrentSelection.addAction(UIAlertAction(title: torrent, style: .default, handler: { _ in
//                selected = Int32(torrents.firstIndex(of:torrent) ?? -1)
//            }))
//        }
//    }

}

struct PreloadTorrentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = PreloadTorrentViewModel(torrent: Torrent(), media: Movie.dummy(), onReadyToPlay: {_ in })
        PreloadTorrentView(viewModel: model)
    }
}
