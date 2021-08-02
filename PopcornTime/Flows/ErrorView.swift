//
//  ErrorView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 28.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    var error: Error
    
    var body: some View {
        VStack {
            let info = displayInfo
            Text(info.title)
                .font(.title2)
                .padding()
            Text(info.description)
                .font(.callout)
                .foregroundColor(.init(white: 1.0, opacity: 0.667))
                .frame(maxWidth: 400)
                .multilineTextAlignment(.center)
        }
    }
    
    var displayInfo: (title: String, description: String) {
        if let error = error as? NSError {
            switch error.code {
            case -1200:
                return (
                    "SSL Error".localized,
                    "It looks like your ISP/Network admin is blocking our servers. You can try again with a VPN to hide your internet traffic from them. Please do so at your own risk".localized
                )
            case -404:
                return (
                    "Not found".localized,
                    "Please check your internet connection and try again.".localized
                )
            case -1005, -1009:
                return (
                    "You're Offline".localized,
                    "Please make sure you have a valid internet connection and try again.".localized
                )
            default:
                break
            }
        }
        
        return (
            "Unknown Error".localized, error.localizedDescription
        )
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Some error"]))
    }
}
