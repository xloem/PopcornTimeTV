//
//  Session.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation

enum Session {
    
    @UserDefault(key: "traktCredentials", defaultValue: nil)
    static var traktCredentials: Data?
    
    @UserDefault(key: "skipReleaseVersion", defaultValue: nil)
    static var skipReleaseVersion: Data?
    
    @UserDefault(key: "popcornUrl", defaultValue: nil)
    static var popcornBaseUrl: String?
}
