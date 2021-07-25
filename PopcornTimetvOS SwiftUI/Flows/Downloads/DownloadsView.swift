//
//  DownloadsView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct DownloadsView: View {
    @StateObject var viewModel = DownloadViewModel()
    
    var body: some View {
        emptyView
    }
    
    @ViewBuilder
    var emptyView: some View {
        if viewModel.isEmpty {
            VStack {
                Text("Downloads Empty".localized)
                    .font(.title2)
                    .padding()
                Text("Movies and episodes you download will show up here.".localized)
                    .font(.callout)
                    .foregroundColor(.init(white: 1.0, opacity: 0.667))
                    .frame(maxWidth: 400)
                    .multilineTextAlignment(.center)
            }
        } else {
            ScrollView {
                VStack {
                    downloadingSection
                    movieSection
                    showSection
                }
            }
        }
    }
    
    @ViewBuilder
    var downloadingSection: some View {
        if viewModel.downloading.isEmpty {
            EmptyView()
        }
                
        VStack(alignment: .leading) {
            Text("Downloading".localized)
                .font(.callout)
                .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
                .padding(.top, 14)
            ScrollView(.horizontal) {
                HStack(spacing: 40) {
                    ForEach(viewModel.downloading, id: \.self) { download in
                        NavigationLink(
                            destination:
                                EmptyView(),
                            label: {
                                DownloadView(download: download)
                                    .frame(width: download.isEpisode ? 310 : 240)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
//                            .padding([.leading, .trailing], 10)
                    }
                    .padding(20) // allow zoom
                }.padding(.all, 0)
            }
        }
    }
    
    @ViewBuilder
    var movieSection: some View {
        VStack(alignment: .leading) {
            Text("Movies".localized)
                .font(.callout)
                .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
                .padding(.top, 14)
            ScrollView(.horizontal) {
                HStack(spacing: 40) {
                    ForEach(viewModel.completedMovies, id: \.self) { download in
                        NavigationLink(
                            destination:
                                EmptyView(),
                            label: {
                                DownloadView(download: download)
                                    .frame(width: 240)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
//                            .padding([.leading, .trailing], 10)
                    }
                    .padding(20) // allow zoom
                }.padding(.all, 0)
            }
        }
    }
    
    @ViewBuilder
    var showSection: some View {
        VStack(alignment: .leading) {
            Text("Shows".localized)
                .font(.callout)
                .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
                .padding(.top, 14)
            ScrollView(.horizontal) {
                HStack(spacing: 40) {
                    ForEach(viewModel.completedEpisodes, id: \.self) { download in
                        NavigationLink(
                            destination:
                                EmptyView(),
                            label: {
                                DownloadView(download: download, show: Episode(download.mediaMetadata)?.show)
                                    .frame(width: 240)
                            })
                            .buttonStyle(PlainNavigationLinkButtonStyle())
//                            .padding([.leading, .trailing], 10)
                    }
                    .padding(20) // allow zoom
                }.padding(.all, 0)
            }
        }
    }
}

struct DownloadsView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadsView()
    }
}
