//
//  ColorPallete.swift
//  PopcornTime
//
//  Created by Alexandru Tudose on 19.09.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct ColorPallete {
    let primary: Color
    let secondary: Color
    let tertiary: Color
    
    static let light = ColorPallete(primary: .white,
                                    secondary: Color(white: 1.0, opacity: 0.667),
                                    tertiary: Color(white: 1.0, opacity: 0.333))
    static let dark = ColorPallete(primary: .black,
                                   secondary: Color(white:1, opacity: 0.667),
                                   tertiary: Color(white:1, opacity: 0.333))
}

let item = Color.primary
