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
import MediaPlayer
import Kingfisher

struct DownloadView: View {
    var download: PTTorrentDownload
    var show: Show?
    var isCompleted = true
    
    var body: some View {
        VStack {
            KFImage(URL(string: download.smallCoverImage ?? ""))
                .resizable()
                .placeholder {
                    Image(placeholderImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .shadow(radius: 5)
//                .padding(.bottom, 5)
            Text(download.title)
                .font(.system(size: 28, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .shadow(color: .init(white: 0, opacity: 0.6), radius: 2, x: 0, y: 1)
                .padding(0)
                .zIndex(10)
//                .frame(height: 80)
            Text(detailText)
                .font(.system(size: 20, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .shadow(color: .init(white: 0, opacity: 0.6), radius: 2, x: 0, y: 1)
                .padding(0)
                .zIndex(10)
        }
    }
    
    var placeholderImage: String {
        return show != nil ? "Episode Placeholder" : "Movie Placeholder"
    }
    
    var detailText: String {
        return isCompleted ? download.fileSize.stringValue : downloadingDetailText
    }
    
    var downloadingDetailText: String {
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
}

struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadView(download: PTTorrentDownload(mediaMetadata: [:], downloadStatus: .finished))
    }
}


extension PTTorrentDownload {
    var title: String {
        return mediaMetadata[MPMediaItemPropertyTitle] as? String ?? ""
    }
    
    var smallCoverImage: String? {
        return mediaMetadata[MPMediaItemPropertyBackgroundArtwork]  as? String
    }
    
    var isEpisode: Bool {
        Episode(mediaMetadata)?.show != nil
    }
}
