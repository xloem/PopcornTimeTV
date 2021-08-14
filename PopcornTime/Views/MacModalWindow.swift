//
//  MacModalWindow.swift
//  MacModalWindow
//
//  Created by Alexandru Tudose on 14.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct MacModalWindow<Content: View, Modal: View>: View {
    @Binding var isActive: Bool
    var title: String
    var content: Content
    var modalView: () -> Modal
    
    @State var window: NSWindow?
    @StateObject var viewModel = MacModalWindowModel()
    
    var body: some View {
        content
            .onChange(of: isActive) { newValue in
                if newValue {
                    showWindow()
                } else {
                    closeWindow()
                }
            }
    }
    
    func showWindow() {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 720), styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],  backing: .buffered, defer: false)
        viewModel.isActive = $isActive
        guard let window = window else {
            return
        }

        window.delegate = viewModel
        
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("VideoPlayer")
        window.title = title
        window.contentView = NSHostingView(rootView: modalView())
        window.level = .normal
//        let mainScreen: NSScreen = NSScreen.screens[0]
//        playerWindow.contentView?.enterFullScreenMode(mainScreen, withOptions: [.])
        window.makeKeyAndOrderFront(nil)
    }
    
    func closeWindow() {
        window?.close()
        window = nil
    }
}

extension View {
    @ViewBuilder
    func fullScreenModal<Content: View>(isActive: Binding<Bool>, title: String, modalView: @escaping () -> Content) -> some View {
        MacModalWindow(isActive: isActive, title: title, content: self, modalView:modalView)
    }
}

class MacModalWindowModel: NSObject, ObservableObject, NSWindowDelegate {
    
    var isActive: Binding<Bool> = .constant(false)
    
    func windowWillClose(_ notification: Notification) {
        isActive.wrappedValue = false
    }
}
