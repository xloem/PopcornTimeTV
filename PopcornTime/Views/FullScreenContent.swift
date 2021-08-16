//
//  FullScreenContent.swift
//  FullScreenContent
//
//  Created by Alexandru Tudose on 16.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

extension View {
    /// show content as fullscreen Cover on iOS / tvOS or as a separate window on Mac
    @ViewBuilder
    func fullScreenContent<Content: View>(isPresented: Binding<Bool>, title: String, content: @escaping () -> Content) -> some View {
        #if os(tvOS) || os(iOS)
        self.fullScreenCover(isPresented: isPresented, content: content)
        #elseif os(macOS)
        self.fullScreenModal(isPresented: isPresented, title: title, modalView: content)
        #endif
    }
}
