//
//  VLCPlayerView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 21.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
#if os(tvOS)
import TVVLCKit
typealias VLCPlayerView = VLCPlayerView_tvOS
#elseif os(iOS)
import MobileVLCKit
typealias VLCPlayerView = VLCPlayerView_iOS
#endif



struct VLCPlayerView_iOS: UIViewRepresentable {
    var mediaplayer = VLCMediaPlayer()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        mediaplayer.drawable = view
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        mediaplayer.drawable = uiView
    }
}

struct VLCPlayerView_tvOS: UIViewRepresentable {
    var mediaplayer = VLCMediaPlayer()
    
    var onSwipeUp: (() -> Void)?
    var onSwipeDown: (() -> Void)?
    var onTouchLocationDidChange: ((SiriRemoteGestureRecognizer) -> Void)?
    var onPositionSliderDrag: ((Float) -> Void)?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        mediaplayer.drawable = view
        context.coordinator.addGestures(view: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        mediaplayer.drawable = uiView
    }
    
    func makeCoordinator() -> VLCPlayerCoordinator {
        let coordinator = VLCPlayerCoordinator()
        coordinator.onSwipeDown = onSwipeDown
        coordinator.onSwipeUp = onSwipeUp
        coordinator.onTouchLocationDidChange = onTouchLocationDidChange
        coordinator.onPositionSliderDrag = onPositionSliderDrag
        return coordinator
    }
    
    class VLCPlayerCoordinator: NSObject, UIGestureRecognizerDelegate {
        var onExit: (() -> Void)?
        var onSwipeUp: (() -> Void)?
        var onSwipeDown: (() -> Void)?
        var onTouchLocationDidChange: ((SiriRemoteGestureRecognizer) -> Void)?
        var onPositionSliderDrag: ((Float) -> Void)?

        var lastTranslation: CGFloat = .zero
        var progressBarWidth: CGFloat = 1000.0
        
        func addGestures(view: UIView) {
            let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
            swipeDownGesture.direction = .down
            swipeDownGesture.cancelsTouchesInView = false
            swipeDownGesture.delegate = self
            view.addGestureRecognizer(swipeDownGesture)
            
//            let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpGesture))
//            swipeUpGesture.direction = .up
//            swipeUpGesture.delegate = self
//            view.addGestureRecognizer(swipeUpGesture)
            
            let gesture = SiriRemoteGestureRecognizer(target: self, action: #selector(touchLocationDidChange(_:)))
            gesture.delegate = self
            gesture.require(toFail: swipeDownGesture)
//            gesture.require(toFail: swipeUpGesture)
            view.addGestureRecognizer(gesture)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGestureAction(gesture:)))
            gesture.delegate = self
            gesture.requiresExclusiveTouchType = false
            view.addGestureRecognizer(panGesture)
        }
        
        @objc func touchLocationDidChange(_ gesture: SiriRemoteGestureRecognizer) {
//            if (gesture.touchLocation == .unknown && gesture.isClick && gesture.state == .ended) {
//                onTap?()
//            } else {
//                onTouchLocationDidChange?(gesture)
//            }
        }
        
        @objc func swipeUpGesture() {
            onSwipeUp?()
        }
        
        @objc func swipeDownGesture() {
            onSwipeDown?()
        }
        
        @objc func onPanGestureAction(gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: gesture.view)
            let offset = Float((translation.x - lastTranslation) / progressBarWidth / 8.0)
            
            switch gesture.state {
            case .cancelled:
                fallthrough
            case .ended:
                lastTranslation = 0.0
            case .began:
                fallthrough
            case .changed:
                onPositionSliderDrag?(offset)
                lastTranslation = translation.x
            default:
                return
            }
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}

#if os(tvOS)
extension VLCPlayerView_tvOS {
    
    func addGestures(onSwipeDown: @escaping () -> Void,
                             onSwipeUp: @escaping () -> Void,
                             onTouchLocationDidChange: @escaping (SiriRemoteGestureRecognizer) -> Void,
                             onPositionSliderDrag: @escaping (Float) -> Void) -> Self {

        return Self.init(mediaplayer: mediaplayer, onSwipeUp: onSwipeUp, onSwipeDown: onSwipeDown, onTouchLocationDidChange: onTouchLocationDidChange, onPositionSliderDrag: onPositionSliderDrag)
    }
}

#endif
