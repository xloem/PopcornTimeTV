//
//  NavigationView.swift
//  NavigationView
//
//  Created by Alexandru Tudose on 03.10.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

#if os(macOS)
typealias NavigationView = StackNavigationView
#endif

typealias PushAction = (AnyView) -> ()
struct PushKey: EnvironmentKey {
    static let defaultValue: PushAction = { _ in }
}

typealias PopToRootAction = () -> ()
struct PopToRootKey: EnvironmentKey {
    static let defaultValue: PopToRootAction = { }
}

extension EnvironmentValues {
    var push: PushAction {
        get { self[PushKey.self] }
        set { self[PushKey.self] = newValue }
    }
    
    var popToRoot: PopToRootAction {
        get { self[PopToRootKey.self] }
        set { self[PopToRootKey.self] = newValue }
    }
}

public struct StackNavigationView<Content: View>: View {
    public typealias V = Bool
    
    private var content: Content
    
    @State private var pushed: [AnyView]
    @State private var popped = [AnyView]()
    
    private var canGoBack: Bool { pushed.count > 0 }
    private var canGoForward: Bool { popped.count > 0 }
    
    public var body: some View {
        ZStack(content: {
            content
                .hide(!pushed.isEmpty)
            ForEach(0..<pushed.count, id: \.self) { index in
                pushed[index]
                    .hide(index != pushed.count - 1)
//                    .opacity(index == pushed.count - 1 ? 1 : 0)
//                    .transition(.move(edge: .trailing))
            }
        })
            .environment(\.push, push)
            .environment(\.popToRoot, popToRoot)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: goBack, label: {
                        Image(systemName: "chevron.left")
                    })
                    .disabled(!canGoBack)
                    .keyboardShortcut("[", modifiers: .command)
                }
                ToolbarItem(placement: .navigation) {
                    Button(action: goForward, label: {
                        Image(systemName: "chevron.right")
                    })
                    .disabled(!canGoForward)
                    .keyboardShortcut("]", modifiers: .command)
                }
            }
    }
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self._pushed = State(initialValue: [])
    }
    
    private func push(_ content: AnyView) {
        let view = AnyView(content.id(UUID()))
        pushed.append(view)
        popped.removeAll()
    }
    
    private func goBack() {
        guard let content = pushed.popLast() else { preconditionFailure() }
        
        withAnimation {
            popped.append(content)
        }

    }
    
    private func goForward() {
        guard let content = popped.popLast() else { preconditionFailure() }
        
        withAnimation {
            pushed.append(content)
        }
    }
    
    private func popToRoot() {
        pushed.removeAll()
        popped.removeAll()
    }
}
