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
    @StateObject var viewModel: DownloadButtonViewModel
    var onFocus: () -> Void = {}
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
        }, onFocus:onFocus)
        .frame(width: 142, height: 115)
    }
    
    var downloadedButton: some View {
        Group {
            NavigationLink(destination: TorrentPlayerView(torrent: viewModel.torrent ?? Torrent(), media: viewModel.media),
                           isActive: $showPlayer,
                           label: {
                EmptyView()
            })
            .hidden()
            
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
            .frame(width: 142, height: 115)
            .actionSheet(isPresented: $viewModel.showDownloadedActionSheet) {
                ActionSheet(title: Text(""),
                            message: nil,
                            buttons: [
                                .default(Text("Play".localized)) {
                                    showPlayer = true
                                },
                                .destructive(Text("Delete Download".localized)) {
                                    viewModel.deleteDownload()
                                },
                                .cancel()
                            ]
                )
            }
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
        .frame(width: 142, height: 115)
        .actionSheet(isPresented: $viewModel.showStopDownloadAlert) {
            ActionSheet(title: Text( "Stop Download".localized),
                        message: Text("Are you sure you want to stop the download?".localized),
                        buttons: [
                            .cancel(),
                            .destructive(Text("Stop".localized)) {
                              self.viewModel.stopDownload()
                            }
                        ]
            )
        }
        .actionSheet(isPresented: $viewModel.showDownloadFailedAlert) {
            ActionSheet(title: Text( "Download Failed".localized),
                        message: Text(viewModel.downloadError?.localizedDescription ?? ""),
                        buttons: [
                            .default(Text("OK".localized))
                        ]
            )
        }
//        .alert(isPresented: $viewModel.showStopDownloadAlert, content: {
//            Alert(title: Text( "Stop Download".localized),
//                  message: Text("Are you sure you want to stop the download?".localized),
//                  primaryButton: .cancel(),
//                  secondaryButton: .destructive(Text("Stop".localized)) {
//                    self.viewModel.stopDownload()
//                  })
//        })
//        .alert(isPresented: $viewModel.showDownloadFailedAlert, content: {
//            Alert(title: Text( "Download Failed".localized),
//                  message: Text(viewModel.downloadError?.localizedDescription ?? ""),
//                  dismissButton: .default(Text("OK".localized)))
//        })
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
        .frame(width: 142, height: 115)
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
        .frame(width: 142, height: 115)
    }
}

struct DownloadButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            ForEach(DownloadButtonViewModel.State.allCases, id: \.self) { state in
                DownloadButton(viewModel: self.model(state: state))
                    .buttonStyle(TVButtonStyle())
                    .background(Color.blue)
            }
        }
        .padding(20)
        .buttonStyle(TVButtonStyle())
        .previewLayout(.fixed(width: 300, height: 750))
    }
    
    static func model(state: DownloadButtonViewModel.State) -> DownloadButtonViewModel {
        let model = DownloadButtonViewModel(media: Movie.dummy())
        model.state = state
        return model
    }
}
