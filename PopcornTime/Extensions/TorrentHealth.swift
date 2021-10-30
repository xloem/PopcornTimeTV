//
//  TorrentHealth.swift
//  PopcornTime
//
//  Created by Alexandru Tudose on 30.10.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

extension Health {
    /**
     - Bad:         Red.
     - Medium:      Orange.
     - Good:        Yellow-green.
     - Excellent:   Bright green.
     - Unknown:     Grey.
     */
    public var color: Color {
        switch self {
        case .bad:
            return Color(red: 212.0/255.0, green: 14.0/255.0, blue: 0.0)
        case .medium:
            return Color(red: 212.0/255.0, green: 120.0/255.0, blue: 0.0)
        case .good:
            return Color(red: 201.0/255.0, green: 212.0/255.0, blue: 0.0)
        case .excellent:
            return Color(red: 90.0/255.0, green: 186.0/255.0, blue: 0.0)
        case .unknown:
            return Color(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0)
        }
    }

    public var image: some View {
        Circle()
            .fill(self.color)
            .frame(width: 10, height: 10)
    }
}
