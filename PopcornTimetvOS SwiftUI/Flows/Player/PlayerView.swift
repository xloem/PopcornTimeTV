//
//  PlayerView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
struct PlayerView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @Environment(\.presentationMode) var presentationMode
    
//    @GestureState var isDetectingLongPress = false
    
    @Namespace private var namespace
    @Environment(\.resetFocus) var resetFocus
    
    var body: some View {
        ZStack {
            VLCPlayerView(mediaplayer: viewModel.mediaplayer, onTap: {
                withAnimation(.spring()) {
                    if viewModel.showControls {
                        viewModel.clickGesture()
                    }
                    viewModel.toggleControlsVisible()
                }
            }, onPlayPause: {
//                withAnimation {
//                    viewModel.playandPause()
//                }
            }, onMove:  { direction in
                switch direction {
                case .down:
//                    withAnimation(.spring()) {
                        viewModel.showInfo = true
//                    }
                case .up:
                    withAnimation(.spring()) {
                        viewModel.showControls = true
                    }
                case .left:
                    viewModel.rewind()
                    viewModel.progress.hint = .rewind
                    viewModel.resetIdleTimer()
                case .right:
                    viewModel.fastForward()
                    viewModel.progress.hint = .fastForward
                    viewModel.resetIdleTimer()
                @unknown default:
                    break
                }
            }, onSwipeUp: {
                withAnimation {
                    viewModel.showControls = true
                }
            }, onSwipeDown: {
                withAnimation {
                    viewModel.showInfo = true
                }
            }, onTouchLocationDidChange: { gesture in
                viewModel.touchLocationDidChange(gesture)
            }, onPositionSliderDrag: { offset in
                viewModel.handlePositionSliderDrag(offset: offset)
            }, focused: !viewModel.showInfo)
//            .focusScope(namespace)
            .prefersDefaultFocus(!viewModel.showInfo, in: namespace)
            .focusable(!viewModel.showInfo)
            .onLongPressGesture(minimumDuration: 0.01, perform: {
                withAnimation(.spring()) {
                    if viewModel.showControls {
                        viewModel.clickGesture()
                    }
                    viewModel.toggleControlsVisible()
                }
            })
            .onPlayPauseCommand {
                withAnimation {
                    viewModel.playandPause()
                }
            }
            .onMoveCommand(perform: { direction in
                switch direction {
                case .down:
                    withAnimation(.spring()) {
                        viewModel.showInfo = true
                    }
                case .up:
                    withAnimation(.spring()) {
                        viewModel.showControls = true
                    }
                case .left:
                    viewModel.rewind()
                    viewModel.progress.hint = .rewind
                    viewModel.resetIdleTimer()
                case .right:
                    viewModel.fastForward()
                    viewModel.progress.hint = .fastForward
                    viewModel.resetIdleTimer()
                @unknown default:
                    break
                }
            })
//            .onExitCommand {
//                withAnimation {
//                    viewModel.showInfo = true
//                }
//            }
            
//            dimmerView
            controlsView
                .transition(.move(edge: .bottom))
            
            if viewModel.isLoading {
//                ProgressView()
            }
            if viewModel.showInfo {
                VStack {
                    PlayerOptionsView(media: viewModel.media,
                                      audioDelay: viewModel.audioDelayBinding,
                                      audioProfile: viewModel.audioProfileBinding,
                                      subtitleDelay: viewModel.subtitleDelayBinding,
                                      subtitleEncoding: viewModel.subtitleEncodingBinding,
                                      subtitle: viewModel.subtitleBinding,
                                      namespace: namespace)
//                    .focusScope(namespace)
//                    .focusable()
                    .prefersDefaultFocus(in: namespace)
                    .onExitCommand(perform: {
                        withAnimation(.spring()) {
                            viewModel.showInfo = false
                        }
                    })
                    .onPlayPauseCommand {
                        viewModel.playandPause()
                    }
                    Spacer()
                }
                .zIndex(1)
                .transition(.move(edge: .top))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        resetFocus(in: namespace)
                    }
                }
            }
        }
        .onAppear {
            viewModel.playOnAppear()
            viewModel.presentationMode = presentationMode // this screen can dismissed from viewmodel
        }.onDisappear {
            
        }
        .focusScope(namespace)
        .ignoresSafeArea()
        .actionSheet(isPresented: $viewModel.resumePlaybackAlert, content: {
            ActionSheet(title: Text(""),
                        message: nil,
                        buttons: [
                            .default(Text("Resume Playing".localized)) {
                              self.viewModel.play(resumePlayback: true)
                            },
                            .default(Text("Start from Beginning".localized)) {
                              self.viewModel.play()
                            }
                        ])
        })
    }
    
    @ViewBuilder
    var dimmerView: some View {
        if viewModel.showControls {
            Color(white: 0, opacity: 0.3)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    var controlsView: some View {
        if !viewModel.isLoading && viewModel.showControls {
            VStack {
//                if viewModel.showInfo {
//                    Image("Now Playing Info")
//                        .padding(.top, 40)
//                }
                Spacer()
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)        // Making rectangle transparent
                        .background(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
                        .frame(height: 190)
                    ProgressBarView(progress: viewModel.progress)
//                    ProgressView(value: viewModel.progress.progress)
                        .frame(height: 10)
                        .padding([.leading, .trailing], 90)
                }
            }
        }
    }
    
//     var longPress: some Gesture {
//         LongPressGesture(minimumDuration: 3)
//             .updating($isDetectingLongPress) { currentState, gestureState, transaction in
//                 gestureState = currentState
//             }
//     }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let url = URL(string: "http://www.youtube.com/watch?v=zI2qbr99H64")!
        let loadingModel = PlayerViewModel(media: Movie.dummy(), fromUrl: url, localUrl: url, directory: url, streamer: .shared())
        
        let showControlsModel = PlayerViewModel(media: Movie.dummy(), fromUrl: url, localUrl: url, directory: url, streamer: .shared())
        showControlsModel.isLoading = false
        showControlsModel.showControls = true
        showControlsModel.showInfo = true
        
        
        return Group {
            PlayerView()
                .background(Color.blue)
                .environmentObject(showControlsModel)
            PlayerView()
                .background(Color.blue)
                .environmentObject(loadingModel)
        }
    }
    
    static var dummyPreview: some View {
        let url = URL(string: "http://www.youtube.com/watch?v=zI2qbr99H64")!
        
        let showControlsModel = PlayerViewModel(media: Movie.dummy(), fromUrl: url, localUrl: url, directory: url, streamer: .shared(), testingMode: true)
        showControlsModel.isLoading = false
        showControlsModel.showControls = false
        showControlsModel.showInfo = false
        showControlsModel.isPlaying = true
        showControlsModel.progress = .init(progress: 0.2, isBuffering: false, bufferProgress: 0.7, isScrubbing: false, scrubbingProgress: 0, remainingTime: "03 min", elapsedTime: "05 min", scrubbing: "la la", screenshot: nil, hint: .none)
        
        
        return Group {
            PlayerView()
                .background(Color.blue)
                .environmentObject(showControlsModel)
        }
    }
}


