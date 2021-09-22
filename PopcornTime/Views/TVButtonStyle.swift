//
//  TVButtonStyle.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 20.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import SwiftUI

struct TVButtonStyle: ButtonStyle {
    var onFocus: () -> Void = {} /// tvOS only
    var onPressed: () -> Void = {} /// iOS only
    var isSelected = false /// iOS only
    
    func makeBody(configuration: Self.Configuration) -> some View {
        #if os(tvOS)
        TVButton(configuration: configuration, onFocus: onFocus, onPressed:onPressed, isSelected: false)
        #else
        TVButton(configuration: configuration, onFocus: onFocus, onPressed:onPressed, isSelected: isSelected)
        #endif
    }
}

struct TVButton: View {
    let theme = Theme()
    
    @Environment(\.isFocused) var focused: Bool
    let configuration: ButtonStyle.Configuration
    var onFocus: () -> Void = {} /// tvOS only
    var onPressed: () -> Void = {} /// iOS only
    var isSelected = false /// iOS Only

    var body: some View {
        return configuration.label
            .scaleEffect(scaleValue)
        #if os(tvOS)
            .focusable(true)
        #endif
            .font(.system(size: theme.fontSize, weight: .medium))
            .foregroundColor((focused || configuration.isPressed || isSelected) ? .primary : .appSecondary)
            .animation(.easeOut, value: focused)
            .onChange(of: focused) { newValue in
                if newValue {
                    onFocus()
                }
            }
            .onChange(of: configuration.isPressed) { newValue in
                if newValue {
                    onPressed()
                }
            }
    }
    
    var scaleValue: CGFloat {
        if isSelected {
            return 1.1 // iOS
        }
        
        if focused || configuration.isPressed {
            return theme.scaleEffect
        }
        
        return 1
    }
}


extension TVButton {
    struct Theme {
        let fontSize: CGFloat = value(tvOS: 23, macOS: 16)
        let scaleEffect: CGFloat = value(tvOS: 1.1, macOS: 0.96)
    }
}
