//
//  SeasonPickerView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct SeasonPickerView: View {
    @StateObject var viewModel: SeasonPickerViewModel
    @Binding var selectedSeasonNumber: Int
    @Environment(\.presentationMode) var presentationMode
    @Namespace var namespace
    #if os(tvOS)
    @Environment(\.resetFocus) var resetFocus
    #endif
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            }
            VStack {
                Text(viewModel.show.title)
                    .font(.title)
                ScrollViewReader { scroll in
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(viewModel.seasons, id: \.self) { season in
                                Button(action: {
                                    selectedSeasonNumber = season.number
                                    presentationMode.wrappedValue.dismiss()
                                }, label: {
                                    SeasonView(season: season)
                                })
                                .buttonStyle(PlainButtonStyle(onFocus: {}))
                                .modify(modifier: {
                                    #if os(tvOS)
                                        $0.prefersDefaultFocus(season.number == selectedSeasonNumber, in: namespace)
                                    #endif
                                })
                                .id(season.number)
                            }
                        }
                        .padding()
                    }.onAppear {
                        scroll.scrollTo(selectedSeasonNumber, anchor: .leading)
                        #if os(tvOS)
                        resetFocus(in: namespace)
                        #endif
                    }
                }
            }
            .modify(modifier: {
                #if os(tvOS)
                    $0.focusScope(namespace)
                #endif
            })
        }
        .onAppear {
            viewModel.load()
        }
    }
}

struct SeasonPickerView_Previews: PreviewProvider {
    static var previews: some View {
        let show = Show.dummy()
        let viewModel = SeasonPickerViewModel(show: show)
        return SeasonPickerView(viewModel: viewModel, selectedSeasonNumber: .constant(1))
    }
}
