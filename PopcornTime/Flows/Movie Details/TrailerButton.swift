//
//  TrailerButton.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 21.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import AVKit
import PopcornKit

struct TrailerButton: View {
    var viewModel: TrailerButtonViewModel
    @State var playerObservation: Any?
    @State var showPlayer = false
    
    var body: some View {    
        Button(action: {
            viewModel.loadTrailerUrl { url in
                self.showPlayer = true
            }
        }, label: {
            VStack {
                VisualEffectBlur() {
                    Image("Preview")
                }
                Text("Trailer".localized)
            }
        })
        .frame(width: 142, height: 115)
        .fullScreenCover(isPresented: $showPlayer) {
            trailerVideo
        }
    }
    
    var trailerVideo: some View {
        VideoPlayer(player: viewModel.trailerVidePlayer)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    viewModel.trailerVidePlayer?.play()
                }
                
                self.playerObservation = NotificationCenter.default.addObserver(forName:.AVPlayerItemDidPlayToEndTime, object:nil, queue: .main, using: {_ in
                    self.showPlayer = false
                })
            }.onDisappear {
                viewModel.trailerVidePlayer?.pause()
                viewModel.trailerVidePlayer?.seek(to: .zero)
                self.playerObservation = nil
            }.ignoresSafeArea()
    }
}

struct TrailerButton_Previews: PreviewProvider {
    static var previews: some View {
        TrailerButton(viewModel: TrailerButtonViewModel(movie: Movie.dummy()))
            .buttonStyle(TVButtonStyle())
            .padding(40)
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
