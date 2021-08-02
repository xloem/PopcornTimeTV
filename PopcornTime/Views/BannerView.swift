//
//  BannerView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 02.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct BannerView: View {
    enum `Type` {
        case info
        case warning
        case success
        case error
    }
    
    var error: Error
    var type: Type = .error
    var title: String = "Error".localized
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.callout)
                        .bold()
                    Text(error.localizedDescription)
                        .font(.footnote)
                }
                .frame(minWidth: 300)
                .foregroundColor(Color.white)
                .padding(12)
                .background(type.tintColor)
                .cornerRadius(8)
            }

            Spacer()
        }
    }
}

extension BannerView.`Type` {
    var tintColor: Color {
        switch self {
        case .info:
            return Color(red: 67/255, green: 154/255, blue: 215/255)
        case .success:
            return Color.green
        case .warning:
            return Color.yellow
        case .error:
            return Color.red
        }
    }
}

struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
        BannerView(error: NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "We have this error"]))
    }
}
