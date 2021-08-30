//
//  AirplayView.swift
//  AirplayView
//
//  Created by Alexandru Tudose on 14.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import AVKit

#if os(iOS)
struct AirplayView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let routePickerView = AVRoutePickerView()
        routePickerView.backgroundColor = UIColor.clear
        routePickerView.activeTintColor = UIColor.white
        routePickerView.tintColor = UIColor.gray

        return routePickerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

#elseif os(macOS)
struct AirplayView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let routePickerView = AVRoutePickerView()
        routePickerView.isRoutePickerButtonBordered = false
        routePickerView.setRoutePickerButtonColor(NSColor.white, for: .activeHighlighted)
        routePickerView.setRoutePickerButtonColor(NSColor.white, for: .active)

        return routePickerView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
    }
}
#endif

struct AirplayView_Previews: PreviewProvider {
    static var previews: some View {
        AirplayView()
            .frame(width: 150, height: 150)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
