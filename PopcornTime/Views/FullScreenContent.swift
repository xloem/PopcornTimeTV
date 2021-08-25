//
//  FullScreenContent.swift
//  FullScreenContent
//
//  Created by Alexandru Tudose on 16.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct NavigationLinkWrapper<Content: View, Destination: View>: View {
    @Binding var isActive: Bool
    var content: Content
    var destination: () -> Destination
    
    var body: some View {
        ZStack {
            NavigationLink(isActive: $isActive, destination: destination, label: { EmptyView() })
                .hidden()
            content
        }
    }
}

extension View {
    /// show content as fullscreen Cover on iOS / tvOS or as a separate window on Mac
    @ViewBuilder
    func fullScreenContent<Content: View>(isPresented: Binding<Bool>, title: String, content: @escaping () -> Content) -> some View {
        #if os(tvOS)
        // using fullscreenCover -> doesn't trigger onAppear/onDisappear and is messing with background music that is stopped onDissapear
//        NavigationLinkWrapper(isActive: isPresented, content: self, destination: content)
        self.fullScreenCover(isPresented: isPresented, content: content)
        #elseif os(iOS)
        self.fullScreenCover(isPresented: isPresented, content: {
            NavigationView {
                content()
            }
        })
        #elseif os(macOS)
        self.fullScreenModal(isPresented: isPresented, title: title, modalView: content)
        #endif
    }
}
