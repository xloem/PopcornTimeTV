import SwiftUI

struct PlainNavigationLinkButtonStyle: ButtonStyle {
    var onFocus: () -> Void = {}
    
    func makeBody(configuration: Self.Configuration) -> some View {
        PlainNavigationLinkButton(configuration: configuration, onFocus: onFocus)
    }
}

fileprivate struct Theme {
    let scaleEffect: CGFloat = value(tvOS: 1.1, macOS: 0.95)
}

struct PlainNavigationLinkButton: View {
    private let theme = Theme()
    @Environment(\.isFocused) var focused: Bool
    let configuration: ButtonStyle.Configuration
    var onFocus: () -> Void = {}

    var body: some View {
        configuration.label
            .scaleEffect(focused || configuration.isPressed ? theme.scaleEffect : 1)
            .foregroundColor((focused || configuration.isPressed) ? Color.primary : Color.appSecondary)
            .animation(.easeOut, value: focused)
            .onChange(of: focused) { newValue in
                if newValue {
                    onFocus()
                }
            }
    }
}




struct PlainButtonStyle: ButtonStyle {
    let onFocus: () -> Void
    
    func makeBody(configuration: Self.Configuration) -> some View {
        PlainButton(configuration: configuration, onFocus: onFocus)
    }
}

struct PlainButton: View {
    private let theme = Theme()
    @Environment(\.isFocused) var focused: Bool
    let configuration: ButtonStyle.Configuration
    let onFocus: () -> Void

    var body: some View {
        configuration.label
            .scaleEffect(focused || configuration.isPressed ? theme.scaleEffect : 1)
            .foregroundColor((focused || configuration.isPressed) ? .primary : .appGray)
            .animation(.easeOut, value: focused)
            .onChange(of: focused) { newValue in
                if newValue {
                    onFocus()
                }
            }
    }
}
