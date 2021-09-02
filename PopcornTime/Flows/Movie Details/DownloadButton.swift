//
//  DownloadButton.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 24.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornTorrent
import PopcornKit

struct DownloadButton: View {
    struct Theme {
        let buttonWidth: CGFloat = value(tvOS: 142, macOS: 100)
        let buttonHeight: CGFloat = value(tvOS: 115, macOS: 81)
    }
    let theme = Theme()
    
    @ObservedObject var viewModel: DownloadButtonViewModel
    @State var showPlayer = false
    
    var body: some View {
        switch viewModel.state {
        case .normal:
            chooseQualityButton
        case .downloaded:
            downloadedButton
        case .downloading:
            downloadingButton
        case .paused:
            pausedButton
        case .pending:
            pendingButton
        }
    }
    
    var chooseQualityButton: some View {
        SelectTorrentQualityButton(media: viewModel.media, action: { torrent in
            viewModel.download(torrent: torrent)
        }, label: {
            VStack {
                VisualEffectBlur() {
                    Image("Download Progress Start")
                }
                Text("Download".localized)
            }
        })
        .frame(width: theme.buttonWidth, height: theme.buttonHeight)
    }
    
    var downloadedButton: some View {    
        Button(action: {
            viewModel.showDownloadedActionSheet = true
        }, label: {
            VStack {
                VisualEffectBlur() {
                    Image("Download Progress Finished")
                }
                Text("Options".localized)
            }
        })
        .frame(width: theme.buttonWidth, height: theme.buttonHeight)
        .confirmationDialog("", isPresented: $viewModel.showDownloadedActionSheet, actions: {
            Button { showPlayer = true } label: { Text("Play".localized) }
            Button(role: .destructive) {
                viewModel.deleteDownload()
            } label: {
                Text("Delete Download".localized)
            }
            Button(role: .cancel, action: {}, label: { Text("Cancel") })
        })
        .fullScreenContent(isPresented: $showPlayer, title: viewModel.media.title) {
            TorrentPlayerView(torrent: viewModel.torrent ?? Torrent(), media: viewModel.media)
        }
    }
    
    var downloadingButton: some View {
        Button(action: {
            viewModel.showStopDownloadAlert = true
        }, label: {
            VStack {
                VisualEffectBlur() {
//                    Image("Download Progress Pause")
                    DownloadProgressView(progress: viewModel.downloadProgress)
                        .padding(.all, 5)
                }
                Text("Downloading".localized)
            }
        })
        .frame(width: theme.buttonWidth, height: theme.buttonHeight)
        .confirmationDialog(
            Text("Are you sure you want to stop the download?".localized),
            isPresented: $viewModel.showStopDownloadAlert,
            titleVisibility: .visible,
            actions: {
                     Button(role: .cancel, action: {}, label: { Text("Cancel") })
                     Button(role: .destructive, action: {
                         self.viewModel.stopDownload()
                     }, label: { Text("Stop".localized) })
        })

        .alert(isPresented: $viewModel.showDownloadFailedAlert, content: {
            Alert(title: Text( "Download Failed".localized),
                  message: Text(viewModel.downloadError?.localizedDescription ?? ""),
                  dismissButton: .cancel(Text("OK".localized)))
        })
    }
    
    var pausedButton: some View {
        Button(action: {
            viewModel.resumeDownload()
        }, label: {
            VStack {
                VisualEffectBlur() {
                    Image("Download Progress Pause")
                }
                Text("Paused".localized)
            }
        })
        .frame(width: theme.buttonWidth, height: theme.buttonHeight)
    }
    
    var pendingButton: some View {
        Button(action: {
            viewModel.stopDownload()
        }, label: {
            VStack {
                VisualEffectBlur() {
                    Image("Download Progress Indeterminate")
                        .modifier(RotateAnimation())
                }
                Text("Pending".localized)
            }
        })
        .frame(width: theme.buttonWidth, height: theme.buttonHeight)
    }
}

struct DownloadButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            ForEach(DownloadButtonViewModel.State.allCases, id: \.self) { state in
                DownloadButton(viewModel: self.model(state: state))
            }
        }
        .padding(20)
        .buttonStyle(TVButtonStyle())
        .previewLayout(.fixed(width: 300, height: 750))
        .preferredColorScheme(.dark)
    }
    
    static func model(state: DownloadButtonViewModel.State) -> DownloadButtonViewModel {
        let model = DownloadButtonViewModel(media: Movie.dummy())
        model.state = state
        return model
    }
}
