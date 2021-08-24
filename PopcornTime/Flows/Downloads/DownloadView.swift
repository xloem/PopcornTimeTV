//
//  DownloadView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 25.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornTorrent
import PopcornKit
import Kingfisher

struct DownloadView: View {
    struct Theme {
        let titleSize: CGFloat = value(tvOS: 28, macOS: 20)
        let detailSize: CGFloat = value(tvOS: 20, macOS: 16)
    }
    let theme = Theme()
    
    @StateObject var viewModel: DownloadViewModel
    @State var showDeleteAction = false
    @State var showActions = false
    
    @State var torrent: Torrent?
    @State var showPlayer = false
    
    var body: some View {
        Button(action: {
            showActions = true
        }, label: {
            VStack {
                Color.clear
                    .background {
                        KFImage(URL(string: imageUrl))
                            .resizable()
                            .placeholder {
                                Image(placeholderImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                            .aspectRatio(contentMode: .fill)
                    }
                    .overlay(alignment: .bottom) {
                        if viewModel.download.downloadStatus == .downloading {
                            ProgressView(value: viewModel.download.torrentStatus.totalProgress)
                                .padding([.leading, .trailing, .bottom], 15)
                        }
                    }
                    .clipped()
                    .cornerRadius(10)
                    .shadow(radius: 5)
                
                Text(title)
                    .font(.system(size: theme.titleSize, weight: .medium))
                    .lineLimit(1)
                    .shadow(color: .init(white: 0, opacity: 0.6), radius: 2, x: 0, y: 1)
                    .padding(0)
                
                Text(detailText)
                    .font(.system(size: theme.detailSize, weight: .medium))
                    .lineLimit(1)
                    .shadow(color: .init(white: 0, opacity: 0.6), radius: 2, x: 0, y: 1)
                    .padding(0)
            }
        })
        .buttonStyle(PlainNavigationLinkButtonStyle())
        .confirmationDialog("Are you sure you want to delete the download?", isPresented: $showDeleteAction, titleVisibility: .visible, actions: {
            deleteAction
//                .disableObserverOnAppear(viewModel: viewModel)
        })
        .confirmationDialog("", isPresented: $showActions, actions: {
            downloadActions
//                .disableObserverOnAppear(viewModel: viewModel)
        })
        .fullScreenContent(isPresented: $showPlayer, title: viewModel.media.title) {
            TorrentPlayerView(torrent: viewModel.torrent, media: viewModel.media)
        }
        .onAppear {
            viewModel.addObserver()
        }
        .onDisappear {
            viewModel.observation = nil
        }
    }
    
    var placeholderImage: String {
        return viewModel.download.show != nil ? "Episode Placeholder" : "Movie Placeholder"
    }
    
    var imageUrl: String {
        return (viewModel.download.show != nil ? viewModel.download.show?.smallCoverImage : viewModel.download.smallCoverImage) ?? ""
    }
    
    var title: String {
        if let episode = Episode(viewModel.download.mediaMetadata) {
            return "\(episode.episode). " + episode.title
        } else {
            return viewModel.download.title
        }
    }
        
    var detailText: String {
        return viewModel.download.isCompleted ? viewModel.download.fileSize.stringValue : downloadingDetailText
    }
    var contentMode: SwiftUI.ContentMode {
        viewModel.download.show != nil ? .fill : .fit
    }
    
    var downloadingDetailText: String {
        let download = viewModel.download
        let speed: String
        let downloadSpeed = TimeInterval(download.torrentStatus.downloadSpeed)
        let sizeLeftToDownload = TimeInterval(download.fileSize.longLongValue - download.totalDownloaded.longLongValue)
        
        if downloadSpeed > 0 {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .full
            formatter.includesTimeRemainingPhrase = true
            formatter.includesApproximationPhrase = true
            formatter.allowedUnits = [.hour, .minute]
            
            let remainingTime = sizeLeftToDownload/downloadSpeed
            if remainingTime < 60 { // seconds
                formatter.allowedUnits = [.second]
            }
            
            if let formattedTime = formatter.string(from: remainingTime) {
                speed = " • " + formattedTime
            } else {
                speed = ""
            }
        } else {
            speed = ""
        }
        
        return download.downloadStatus == .paused ?  "Paused".localized : ByteCountFormatter.string(fromByteCount: Int64(download.torrentStatus.downloadSpeed), countStyle: .binary) + "/s" + speed
    }
    
    @ViewBuilder
    var deleteAction: some View {
        Button(role: .destructive, action: {
            viewModel.delete()
        }, label: {
            Text("Delete")
        })
    }
    
    @ViewBuilder
    var downloadActions: some View {
        let deleteDownload = Button(role: .destructive, action: {
            showDeleteAction = true
        }, label: {
            Text("Delete Download")
        })
        
        switch viewModel.download.downloadStatus {
        case .finished:
            Button(action: {
                showPlayer = true
            }, label: {
                Text("Play")
            })
            
            deleteDownload
        case .downloading, .processing:
            Button(action: {
                viewModel.pause()
            }, label: {
                Text("Pause")
            })
        case .paused:
            Button(action: {
                viewModel.continueDownload()
            }, label: {
                Text("Continue Download")
            })
        
            deleteDownload
        case .failed:
            deleteDownload
        @unknown default: EmptyView()
        }
    }
}

extension View {
    fileprivate func disableObserverOnAppear(viewModel: DownloadViewModel) -> some View {
        onAppear {
            viewModel.observation = nil
        }
        .onDisappear {
            viewModel.addObserver()
        }
    }
}

struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            DownloadView(viewModel: DownloadViewModel(download: PTTorrentDownload.dummy(status: .processing)))
//                .previewDisplayName("Processing")

//            DownloadView(viewModel: DownloadViewModel(download: PTTorrentDownload.dummyEpisode(status: .paused)))
//                .frame(width: 310, height: 245)
//                .previewDisplayName("Paused")
            
//            DownloadView(viewModel: DownloadViewModel(download: PTTorrentDownload.dummy(status: .failed)))
//                .frame(width: 500, height: 400)
//                .previewDisplayName("Failed")
            
            DownloadView(viewModel: DownloadViewModel(download: PTTorrentDownload.dummyEpisode(status: .downloading)))
                .previewDisplayName("Downloading")
        
//            DownloadView(viewModel: DownloadViewModel(download: PTTorrentDownload.dummy(status: .downloading)))
//                .previewDisplayName("Downloading")
            
//            DownloadView(viewModel: DownloadViewModel(download: PTTorrentDownload.dummy(status: .finished)))
//                .frame(width: 250, height: 460)
//                .background(.blue)
//                .previewDisplayName("Finished")
        }
        .frame(width: 310, height: 245)
        .previewLayout(.sizeThatFits)
    }
}




