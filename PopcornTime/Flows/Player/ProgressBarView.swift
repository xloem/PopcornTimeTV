//
//  ProgressBarView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 21.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct ProgressBarView: UIViewRepresentable {
    var progress: PlayerViewModel.Progress
    @State var view = ProgressBar()
    
    func makeUIView(context: Context) -> ProgressBar {
        return view
    }
    
    func updateUIView(_ uiView: ProgressBar, context: Context) {
        uiView.bufferProgress = progress.bufferProgress
        uiView.elapsedTimeLabel.text = progress.elapsedTime
        uiView.isBuffering = progress.isBuffering
        uiView.isScrubbing = progress.isScrubbing
        uiView.progress = progress.progress
        uiView.remainingTimeLabel.text = progress.remainingTime
        uiView.screenshot = progress.screenshot
        uiView.scrubbingProgress = progress.scrubbingProgress
        uiView.scrubbingTimeLabel.text = progress.scrubbingTime
        uiView.hint = progress.hint
    }
}
