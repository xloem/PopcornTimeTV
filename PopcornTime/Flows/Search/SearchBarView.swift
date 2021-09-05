//
//  SearchBarView.swift
//  SearchBarView
//
//  Created by Alexandru Tudose on 05.09.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    enum Field: Hashable {
        case search
    }
     
    @FocusState private var focused: Field?
 
    var body: some View {
        HStack {
            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($focused, equals: .search)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                 
                        if focused == .search && text.count > 0 {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                                    .padding([.top, .leading, .bottom])
                            }
                        }
                    }
                )
 
            if focused == .search {
                Button(action: {
//                    self.text = ""
                    self.focused = nil
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(text: .constant(""))
            .previewLayout(.sizeThatFits)
            .padding()
        
        SearchBarView(text: .constant("23"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
