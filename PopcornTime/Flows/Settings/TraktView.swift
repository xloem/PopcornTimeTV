//
//  TraktView.swift
//  PopcornTime
//
//  Created by Alexandru Tudose on 18.09.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct TraktView: View {
    @StateObject var viewModel: TraktViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VisualEffectBlur()
                .ignoresSafeArea()
            VStack {
                Spacer()
                Text("Trakt Pairing Request")
                    .font(.title3)
                Text("Navigate to https://trakt.tv/activate and enter code shown below when asked.")
                    .font(.system(size: 33, weight: .medium))
                    .padding(.top, 20)
                if let code = viewModel.displayCode {
                    Text(code)
                        .font(.largeTitle)
                        .padding(.top, 90)
                }
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .font(.system(size: 33, weight: .medium))
                        .padding(.top, 20)
                }
                Spacer()
                Spacer()
            }
        }
        .foregroundColor(.init(white: 1, opacity: 0.667))
        .onAppear(perform: {
            viewModel.getNewCode()
        })
        .onDisappear {
            viewModel.stopTimer()
        }
    }
}

struct TraktView_Previews: PreviewProvider {
    static var previews: some View {
        TraktView(viewModel: TraktViewModel(onSuccess: {}))
        TraktView(viewModel: codeModel)
    }
    
    static var codeModel: TraktViewModel {
        let model = TraktViewModel(onSuccess: {})
        model.displayCode = "3413"
        return model
    }
}
