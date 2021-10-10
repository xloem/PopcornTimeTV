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

typealias PushAction = (_ view: AnyView, _ binding: Binding<Bool>?) -> ()
struct PushKey: EnvironmentKey {
    static let defaultValue: PushAction = { _, _ in }
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

struct MacDismissAction {
    var action: () -> Void
    
    public func callAsFunction() {
        action()
    }
}

struct MacDismissActionKey: EnvironmentKey {
    static let defaultValue: MacDismissAction = .init(action: { })
}

extension EnvironmentValues {
    var macDismiss: MacDismissAction {
        get { self[MacDismissActionKey.self] }
        set { self[MacDismissActionKey.self] = newValue }
    }
}

public struct StackNavigationView<Content: View>: View {
    public typealias V = Bool
    
    private var content: Content
    
    @State private var pushed: [(view: AnyView, binding: Binding<Bool>?)]
    @State private var popped: [(view: AnyView, binding: Binding<Bool>?)] = []
    
    private var canGoBack: Bool { pushed.count > 0 }
    private var canGoForward: Bool { popped.count > 0 }
    
    public var body: some View {
        ZStack(content: {
            content
                .hide(!pushed.isEmpty)
            
            ForEach(0..<pushed.count, id: \.self) { index in
                pushed[index].view
                    .hide(index != pushed.count - 1)
                    .environment(\.macDismiss, MacDismissAction(action: {
                        goBack(index: index)
                    }))
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
    
    private func push(_ content: AnyView, _ binding: Binding<Bool>?) {
        let view = AnyView(content.id(UUID()))
        pushed.append((view, binding))
        binding?.wrappedValue = true
        popped.removeAll()
    }
    
    private func goBack() {
        guard let content = pushed.popLast() else { preconditionFailure() }
        
        withAnimation {
            content.binding?.wrappedValue = false
            popped.append(content)
        }
    }
    private func goBack(index: Int) {
        for _ in index..<pushed.count {
            guard let content = pushed.popLast() else { preconditionFailure() }
            content.binding?.wrappedValue = false
            popped.append(content)
        }
    }
    
    private func goForward() {
        guard let content = popped.popLast() else { preconditionFailure() }
        
        withAnimation {
            content.binding?.wrappedValue = true
            pushed.append(content)
        }
    }
    
    private func popToRoot() {
        pushed.reversed().forEach({ $0.binding?.wrappedValue = false })
        pushed.removeAll()
        popped.removeAll()
    }
}
