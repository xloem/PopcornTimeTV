//
//  PlayerControlsView.swift
//  PlayerControlsView
//
//  Created by Alexandru Tudose on 14.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct PlayerControlsView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            topView
            Spacer()
            bottomView
        }
        .accentColor(.white)
    }
    
    @ViewBuilder
    var topView: some View {
        #if os(iOS)
        HStack(alignment: .center, spacing: 0) {
            closeButton
                .background(.regularMaterial)
            ratioButton
                .background(.regularMaterial)
            Spacer()
            VolumeButtonSlider()
                .frame(width: 200)
                .background(.regularMaterial)
        }
        .frame(height: 46)
        .padding(.top, 10)
        #else
        EmptyView()
        #endif
    }
    
    @ViewBuilder
    var bottomView: some View {
        HStack(spacing: 10) {
            rewindButton
            playButton
                .padding(.leading, 10)
            forwardButton
                .padding(.leading, 10)
            Text(viewModel.progress.isScrubbing ? viewModel.progress.scrubbingTime : viewModel.progress.elapsedTime)
            #if os(iOS)
                .monospacedDigit()
            #endif
                .foregroundColor(.gray)
                .frame(minWidth: 40)
            progressView
            Text(viewModel.progress.remainingTime)
            #if os(iOS)
                .monospacedDigit()
            #endif
                .foregroundColor(.gray)
                .frame(minWidth: 40)
//            AirplayView()
//                .frame(width: 40)
            subtitlesButton
        }
        #if os(iOS)
        .tint(.white)
        #endif
        .frame(height: 45)
        .padding([.leading, .trailing], 10)
        #if os(iOS)
        .background(.regularMaterial)
        #endif
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    var progressView: some View {
        ZStack {
            if viewModel.isLoading {
                HStack(spacing: 10) {
                    Spacer()
                    ProgressView()
                    Text("Loading...".localized)
                    Spacer()
                }
            } else {
                ProgressView(value: viewModel.progress.bufferProgress)
                    .padding(.top, 1)
                    .padding([.leading, .trailing], 1)
                #if os(iOS)
                    .tint(.gray)
                #endif
                Slider(value: Binding(get: {
                    viewModel.progress.isScrubbing ? viewModel.progress.scrubbingProgress : viewModel.progress.progress
                }, set: { value in
                    viewModel.progress.scrubbingProgress = value
                    viewModel.positionSliderDidDrag()
                })) { started in
                        viewModel.clickGesture()
                }
            }
        }
    }
    
    @ViewBuilder
    var closeButton: some View {
        Button {
            withAnimation {
                presentationMode.wrappedValue.dismiss()
            }
        } label: {
            Color.clear
                .overlay(Image("CloseiOS"))
        }
        .frame(width: 46)
    }
    
    @ViewBuilder
    var ratioButton: some View {
        #if os(iOS)
        Button {
            viewModel.switchVideoDimensions()
        } label: {
            Color.clear
                .overlay{
                    Image(viewModel.videoAspectRatio == .fit ?  "Scale To Fill" : "Scale To Fit")
                        .resizable()
                        .renderingMode(.template)
                        .tint(.gray)
                        .frame(width: 22, height: 22)
                }
        }
        .frame(width: 46)
        #else
        EmptyView()
        #endif
    }
    
    @ViewBuilder
    var playButton: some View {
        Button {
            viewModel.playandPause()
        } label: {
            viewModel.isPlaying ? Image("Pause") : Image("Play")
        }
        .disabled(viewModel.isLoading)
        .frame(width: 32)
    }
    
    @ViewBuilder
    var rewindButton: some View {
        Button {
            viewModel.rewind()
        } label: {
            Image("Rewind")
        }
        .onLongPressGesture(perform: {}, onPressingChanged: { started in
            viewModel.rewindHeld(started)
        })
        .disabled(viewModel.isLoading || viewModel.progress.progress == 0.0)
        .frame(width: 32)
    }
    
    @ViewBuilder
    var forwardButton: some View {
        Button {
            viewModel.fastForward()
        } label: {
            Image("Fast Forward")
        }
        .disabled(viewModel.isLoading || viewModel.progress.progress == 1.0)
        .onLongPressGesture(perform: {}, onPressingChanged: { started in
            viewModel.fastForwardHeld(started)
        })
        .frame(width: 32)
    }
    
    @ViewBuilder
    var airplayButton: some View {
        Image("AirPlay")
        #if os(iOS)
        .tint(.gray)
        #endif
        .frame(width: 32)
    }
    
    @ViewBuilder
    var subtitlesButton: some View {
        Button {
            
        } label: {
            Image("Subtitles")
        }
        #if os(iOS)
        .tint(.gray)
        #endif
        .frame(width: 32)
    }
}

struct PlayerControlsView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerControlsView()
            .preferredColorScheme(.dark)
            .environmentObject(playingPlayerModel)
        
        PlayerControlsView()
            .preferredColorScheme(.dark)
            .environmentObject(loadingPlayerModel)
    }
    
    static var playingPlayerModel: PlayerViewModel {
        let url = URL(string: "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8")!
        
        let showControlsModel = PlayerViewModel(media: Movie.dummy(), fromUrl: url, localUrl: url, directory: url, streamer: .shared())
        showControlsModel.isLoading = false
        showControlsModel.showControls = false
        showControlsModel.showInfo = false
        showControlsModel.isPlaying = true
        showControlsModel.progress = .init(progress: 0.2, isBuffering: false, bufferProgress: 0.7, isScrubbing: false, scrubbingProgress: 0, remainingTime: "-23:10", elapsedTime: "02:20", scrubbingTime: "la la", screenshot: nil, hint: .none)
        return showControlsModel
    }
    
    static var loadingPlayerModel: PlayerViewModel {
        let url = URL(string: "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8")!
        
        let showControlsModel = PlayerViewModel(media: Movie.dummy(), fromUrl: url, localUrl: url, directory: url, streamer: .shared())
        showControlsModel.isLoading = true
        showControlsModel.progress = .init(progress: 0.1, isBuffering: true, bufferProgress: 0.7, isScrubbing: false, scrubbingProgress: 0, remainingTime: "-23:10", elapsedTime: "01:20", scrubbingTime: "03:04", screenshot: nil, hint: .none)
        return showControlsModel
    }
}
