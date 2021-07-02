//
//  UIDevice+cellular.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 20.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import UIKit
import Reachability

extension Session {
    static var reachability: Reachability = .forInternetConnection()
}

extension UIDevice {
    var hasCellularCapabilites: Bool {
        var addrs: UnsafeMutablePointer<ifaddrs>?
        var cursor: UnsafeMutablePointer<ifaddrs>?
        
        defer { freeifaddrs(addrs) }
        
        guard getifaddrs(&addrs) == 0 else { return false }
        cursor = addrs
        
        while cursor != nil {
            guard
                let utf8String = cursor?.pointee.ifa_name,
                let name = NSString(utf8String: utf8String),
                name == "pdp_ip0"
                else {
                    cursor = cursor?.pointee.ifa_next
                    continue
            }
            return true
        }
        return false
    }
}
