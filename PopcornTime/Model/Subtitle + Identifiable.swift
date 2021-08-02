//
//  Subtitle + Identifiable.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 27.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import PopcornKit

extension Subtitle: Identifiable {
    public var id: String {
        name + language
    }
}
