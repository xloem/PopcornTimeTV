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
                .foregroundColor(.appSecondary)
                .frame(maxWidth: 400)
                .multilineTextAlignment(.center)
        }
    }
    
    var displayInfo: (title: LocalizedStringKey, description: LocalizedStringKey) {
        let error = error as NSError
        
        switch error.code {
        case -1200:
            return (
                "SSL Error",
                "It looks like your ISP/Network admin is blocking our servers. You can try again with a VPN to hide your internet traffic from them. Please do so at your own risk"
            )
        case -404:
            return (
                "Not found",
                "Please check your internet connection and try again."
            )
        case -1005, -1009:
            return (
                "You're Offline",
                "Please make sure you have a valid internet connection and try again."
            )
        default:
            return (
                "Unknown Error", LocalizedStringKey(error.localizedDescription)
            )
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Some error"]))
    }
}
