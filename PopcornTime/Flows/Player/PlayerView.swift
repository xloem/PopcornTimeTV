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
    @Environment(\.dismiss) var dismiss
    
    @Namespace private var namespace
    #if os(tvOS)
    @Environment(\.resetFocus) var resetFocus
    @State var playerHasFocus = true // workaround to make infoView to have focus on appear
    #endif
    
    var body: some View {
        ZStack {
            VLCPlayerView(mediaplayer: viewModel.mediaplayer)
            #if os(tvOS)
                .addGestures(onSwipeDown: {
                    withAnimation {
                        viewModel.showInfo = true
                    }
                }, onSwipeUp: {
                    withAnimation {
                        viewModel.showControls = true
                    }
                }, onTouchLocationDidChange: { gesture in
                    viewModel.touchLocationDidChange(gesture)
                }, onPositionSliderDrag: { offset in
                    viewModel.handlePositionSliderDrag(offset: offset)
                })
                .focusable(playerHasFocus)
                .prefersDefaultFocus(!viewModel.showInfo, in: namespace)
                .onLongPressGesture(minimumDuration: 0.01, perform: {
                    withAnimation {
                        if viewModel.showControls {
                            viewModel.clickGesture()
                        } else {
                            viewModel.toggleControlsVisible()
                        }
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
                        withAnimation {
                            viewModel.showControls = true
                        }
                        viewModel.resetIdleTimer()
                    case .left:
                        if viewModel.showControls {
                            viewModel.rewind()
                            viewModel.progress.hint = .rewind
                            viewModel.resetIdleTimer()
                        }
                    case .right:
                        if viewModel.showControls {
                            viewModel.fastForward()
                            viewModel.progress.hint = .fastForward
                            viewModel.resetIdleTimer()
                        }
                    @unknown default:
                        break
                    }
                })
                .onExitCommand {
                    if viewModel.showInfo {
                        withAnimation{
                            viewModel.showInfo = false
                        }
                    } else if viewModel.showControls {
                        withAnimation{
                            viewModel.showControls = false
                        }
                    } else {
                        viewModel.stop()
                        dismiss()
                    }
                }
            #else
                .onTapGesture {
                    withAnimation {
                        viewModel.toggleControlsVisible()
                    }
                }
            #endif
            controlsView
            showInfoView
        }
        .onAppear {
            viewModel.playOnAppear()
            viewModel.dismiss = dismiss // this screen can dismissed from viewModel
        }.onDisappear {
            viewModel.stop()
        }
        #if os(tvOS)
        .focusScope(namespace)
        .ignoresSafeArea()
        #endif
        .alert("", isPresented: $viewModel.resumePlaybackAlert, actions: {
            resumeActions
        })
    }
    
    @ViewBuilder
    var controlsView: some View {
        if !viewModel.isLoading && viewModel.showControls {
            #if os(tvOS)
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
                        .frame(height: 10)
                        .padding([.leading, .trailing], 90)
                }
            }
                .transition(.move(edge: .bottom))
            #elseif os(iOS) || os(macOS)
            PlayerControlsView()
                .transition(.opacity)
            #endif
        }
    }
    
    @ViewBuilder
    var showInfoView: some View {
        if viewModel.showInfo {
            VStack {
                PlayerOptionsView(media: viewModel.media,
                                  audioDelay: viewModel.audioController.audioDelayBinding,
                                  audioProfile: viewModel.audioController.audioProfileBinding,
                                  subtitleDelay: viewModel.subtitleController.subtitleDelayBinding,
                                  subtitleEncoding: viewModel.subtitleController.subtitleEncodingBinding,
                                  subtitle: viewModel.subtitleController.subtitleBinding)
                #if os(tvOS)
                .prefersDefaultFocus(in: namespace)
                .onExitCommand(perform: {
                    withAnimation(.spring()) {
                        viewModel.showInfo = false
                    }
                })
                .onPlayPauseCommand {
                    viewModel.playandPause()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        resetFocus(in: namespace)
                        playerHasFocus = false
                    }
                }
                .onDisappear {
                    playerHasFocus = true
                }
                #endif
                Spacer()
            }
            .zIndex(1)
            .transition(.move(edge: .top))
        }
    }
    
    @ViewBuilder
    var resumeActions: some View {
        Button(action: {
            self.viewModel.play(resumePlayback: true)
        }, label: {
            Text("Resume Playing")
        })
        
        Button(role: .cancel, action: {
            self.viewModel.play()
        }, label: {
            Text("Start from Beginning")
        })
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let url = URL(string: "http://www.youtube.com/watch?v=zI2qbr99H64")!
        let directory = URL(fileURLWithPath: "/tmp")
        let loadingModel = PlayerViewModel(media: Movie.dummy(), fromUrl: url, localUrl: directory, directory: directory, streamer: .shared())
        
        let showControlsModel = PlayerViewModel(media: Movie.dummy(), fromUrl: url, localUrl: directory, directory: directory, streamer: .shared())
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
    
//    static var dummyPreview: some View {
//        let url = URL(string: "http://www.youtube.com/watch?v=zI2qbr99H64")!
//        let directory = URL(fileURLWithPath: "/tmp")
//        
//        let showControlsModel = PlayerViewModel(media: Movie.dummy(), fromUrl: url, localUrl: directory, directory: directory, streamer: .shared(), testingMode: true)
//        showControlsModel.isLoading = false
//        showControlsModel.showControls = false
//        showControlsModel.showInfo = false
//        showControlsModel.isPlaying = true
//        showControlsModel.progress = .init(progress: 0.2, isBuffering: false, bufferProgress: 0.7, isScrubbing: false, scrubbingProgress: 0, remainingTime: "03 min", elapsedTime: "05 min", scrubbingTime: "la la", screenshot: nil, hint: .none)
//        
//        
//        return Group {
//            PlayerView()
//                .background(Color.blue)
//                .environmentObject(showControlsModel)
//        }
//    }
}


