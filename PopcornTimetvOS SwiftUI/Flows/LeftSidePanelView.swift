//
//  LeftSidePanelView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import SwiftUIFocusGuide

struct LeftSidePanelView: View {
    var sortFilters = NetworkManager.Filters.allCases
    var genreFilters = NetworkManager.Genres.allCases
    
    @State var isActive = false
    @State var selectedFilter: String?
    @Binding var currentSort: MovieManager.Filters
    @Binding var currentGenre: NetworkManager.Genres
    
    enum Selection {
        case sort
        case genre
    }
    @State var selection: Selection?
    @StateObject var focusBag = SwiftUIFocusBag()
    
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "arrow.up.arrow.down")
                })
                .buttonStyle(PlainButtonStyle(onFocus: {
                    selection = .sort
                }))
                .addFocusGuide(using: focusBag, name: "Sort", destinations: [.bottom: "Genre", .right: "Filters"])
                .frame(height: 70)
                .ignoresSafeArea()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "film")
                })
                .buttonStyle(PlainButtonStyle(onFocus: {
                    selection = .genre
                }))
                .addFocusGuide(using: focusBag, name: "Genre", destinations: [.top: "Sort", .right: "Filters"])
                .frame(height: 70)
                Spacer()
            }
            .ignoresSafeArea()
//            .addFocusGuide(using: focusBag, name: "Filter", destinations: [.right: "Filters"])
            .frame(width: 50)
            .frame(maxHeight: .infinity)
            filterView
                .addFocusGuide(using: focusBag, name: "Filters", destinations: [.left: selection == .genre ? "Genre" : "Sort"])
                .frame(width: 350)
                .frame(maxHeight: .infinity)
                .onMoveCommand(perform: { direction in
                    if direction == .right {
                        selection = nil
                    }
                })
                .transition(.opacity)
            
        }
        .onExitCommand(perform: {
            selection = nil
        })
        .background(backgroundView)
        .zIndex(2)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    var filterView: some View {
        switch selection {
        case .sort:
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                ForEach(sortFilters, id: \.self) { sort in
                    button(text: sort.string, isSelected: sort == currentSort) {
                        currentSort = sort
                    }
                }
                Spacer()
            }
//            .frame(maxWidth: 350, maxHeight: .infinity)
//            .addFocusGuide(using: focusBag, name: "SortFilters", destinations: [.left: "Sort"], debug: true)
//            .frame(maxWidth: 350, maxHeight: .infinity)
        case .genre:
//            VStack(spacing: 0) {
                ScrollViewReader { scroll in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            ForEach(genreFilters, id:\.self) { genre in
                                button(text: genre.string, isSelected: genre == currentGenre) {
                                    currentGenre = genre
                                }
                            }
                        }
                    }
                    .onAppear(perform: {
                        scroll.scrollTo(currentGenre, anchor: .center)
                    })
                }
//            .frame(maxWidth: 350, maxHeight: .infinity)
//            .addFocusGuide(using: focusBag, name: "GenreFilters", destinations: [.left: "Genre", .right: "Genre"], debug: true)
//            .frame(maxWidth: 350, maxHeight: .infinity)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    var backgroundView: some View {
        if selection != nil {
            VisualEffectBlur()
                .mask(gradient)
        }
    }
    
    
    func button(text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            HStack(spacing: 20) {
                if (isSelected) {
                    Image(systemName: "checkmark")
                } else {
                    Text("").frame(width: 32)
                }
                Text(text)
                    .font(.system(size: 31, weight: .medium))
            }
            .padding([.leading], 20)
            .padding([.trailing], 50)
        })
//        .padding([.leading, .trailing], 20)
        .buttonStyle(PlainButtonStyle(onFocus: {}))
    }
    
    let gradient = LinearGradient(
         gradient: Gradient(stops: [
            .init(color: .purple, location: 0.6),
            .init(color: .init(white: 1, opacity: 0.8), location: 0.8),
            .init(color: .clear, location: 1)
         ]),
         startPoint: .leading,
         endPoint: .trailing
     )
}

struct LeftSidePanelView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .leading) {
            VStack {
                Spacer()
            }
            .frame(    maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity)
            .background(Color.gray)
            
            LeftSidePanelView(currentSort: .constant(.trending), currentGenre: .constant(.all))
        }
//            .previewLayout(.sizeThatFits)
    }
}
