//
//  LeftSidePanelView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct LeftSidePanelView: View {
    var sortFilters = NetworkManager.Filters.allCases
    var genreFilters = NetworkManager.Genres.allCases
    
    @State var isActive = false
    @State var selectedFilter: String?
    @Binding var currentSort: PopcornApi.Filters
    @Binding var currentGenre: NetworkManager.Genres
    
    enum Selection: Hashable {
        case sort
        case genre
        case externalTorrent
    }
    @State var selection: Selection?
    @FocusState private var focusedFilter: String?
    @FocusState private var focusedType: Selection?
    @State var showExternalTorrent = false
    
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Spacer()
                sortButton
                genreButton
                externalTorrentButton
                Spacer()
            }
            .focusSection()
            .ignoresSafeArea()
            .frame(width: 50)
            .frame(maxHeight: .infinity)
            
            filterView
                .frame(width: 350)
                .frame(maxHeight: .infinity)
                .focusSection()
                .onMoveCommand(perform: { direction in
                    if direction == .right {
                        selection = nil
                    }
                })
            
        }
        .onExitCommand(perform: {
            selection = nil
        })
        .onDisappear {
            selection = nil
        }
        .background(backgroundView)
        .fullScreenContent(isPresented: $showExternalTorrent, title: "") {
            LoadExternalTorrentView()
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    var sortButton: some View {
        Button(action: {
            selection = nil
        }, label: {
            Image(systemName: "arrow.up.arrow.down")
        })
        .buttonStyle(PlainButtonStyle(onFocus: {
            selection = .sort
        }))
        .frame(height: 70)
        .ignoresSafeArea()
        .focused($focusedType, equals: .sort)
    }
    
    @ViewBuilder
    var genreButton: some View {
        Button(action: {
            selection = nil
        }, label: {
            Image(systemName: "film")
        })
        .buttonStyle(PlainButtonStyle(onFocus: {
            selection = .genre
        }))
        .frame(height: 70)
        .focused($focusedType, equals: .genre)
    }
    
    @ViewBuilder
    var externalTorrentButton: some View {
        Button(action: {
            selection = nil
        }, label: {
            Image(systemName: "plus.rectangle.fill")
        })
        .buttonStyle(PlainButtonStyle(onFocus: {
            selection = .externalTorrent
        }))
        .frame(height: 70)
        .focused($focusedType, equals: .externalTorrent)
    }
    
    @ViewBuilder
    var filterView: some View {
        let focused: Any? = focusedType ?? focusedFilter
        
        switch (selection, focused) {
        case (.sort, .some(_)):
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
        case (.genre, .some(_)):
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
        case (.externalTorrent, .some(_)):
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                button(text: "Open External".localized, isSelected: false) {
                    showExternalTorrent = true
                    selection = nil
                }
                Spacer()
            }
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    var backgroundView: some View {
        if selection != nil || focusedFilter != nil {
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
        .focused($focusedFilter, equals: text)
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
