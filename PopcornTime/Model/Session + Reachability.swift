//
//  Session + Reachability.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 02.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import Reachability

extension Session {
    static var reachability: Reachability = .forInternetConnection()
}
