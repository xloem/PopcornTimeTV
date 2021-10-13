

import SwiftUI

extension Color {
    static let appPrimary: Color = Color("AppPrimary")
    static let appSecondary: Color = Color("AppSecondary")
    static let appGray: Color = Color("AppGray")
    static let appLightGray: Color = Color("AppLightGray")
    static let AppTertiary: Color = Color("AppTertiary")
}


enum SubtitleColor: Int32, Codable, CaseIterable {
    case black = 0
    case darkGray  = 0x555555
    case lightGray = 0xAAAAAA
    case white     = 0xFFFFFF
    case gray      = 0x808080
    case red       = 0xFF0000
    case green     = 0x00FF00
    case blue      = 0x0000FF
    case cyan      = 0x00FFFF
    case yellow    = 0xFFFF00
    case magenta   = 0xFF00FF
    case orange    = 0xFF8000
    case purple    = 0x800080
    case brown     = 0x996633
    
    var localizedString: String {
        switch self {
        case .black:
            return "Black".localized
        case .darkGray:
            return "Dark Gray".localized
        case .lightGray:
            return "Light Gray".localized
        case .white:
            return "White".localized
        case .gray:
            return "Gray".localized
        case .red:
            return "Red".localized
        case .green:
            return "Green".localized
        case .blue:
            return "Blue".localized
        case .cyan:
            return "Cyan".localized
        case .yellow:
            return "Yellow".localized
        case .orange:
            return "Orange".localized
        case .purple:
            return "Purple".localized
        case .brown:
            return "Brown".localized
        case .magenta:
            return "Magenta".localized
        }
    }
}
