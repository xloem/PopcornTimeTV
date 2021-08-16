//
//  AirplayView.swift
//  AirplayView
//
//  Created by Alexandru Tudose on 14.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import AVKit

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

struct AirplayView_Previews: PreviewProvider {
    static var previews: some View {
        AirplayView()
    }
}
