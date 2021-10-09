//
//  VisibleToolbarView.swift
//  VisibleToolbarView
//
//  Created by Alexandru Tudose on 09.10.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct VisibleToolbarView<ToolbarContentItem: ToolbarContent>: ViewModifier {
    @State var isVisible = false
    
    @ToolbarContentBuilder var toolbarContent: (_ isVisible: Bool) -> ToolbarContentItem
    
    func body(content: Content) -> some View {
        content
            .onAppear(perform: {
                isVisible = true
            })
            .onDisappear(perform:  {
                isVisible = false
            })
            .toolbar {
                toolbarContent(isVisible)
            }
        
    }
}
