//
//  ClearCache.swift
//  PopcornTime
//
//  Created by Alexandru Tudose on 28.11.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct ClearCache {
    var title: LocalizedStringKey = ""
    var message: LocalizedStringKey = ""
    
    public mutating func emptyCache() {
        do {
            let size = FileManager.default.folderSize(atPath: NSTemporaryDirectory())
            for path in try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory()) {
                try FileManager.default.removeItem(atPath: NSTemporaryDirectory() + "/\(path)")
            }
            title = "Success"
            if size == 0 {
                message = "Cache was already empty, no disk space was reclaimed."
            } else {
                message = "Cleaned \(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))."
            }
        } catch {
            title = "Failed"
            message = "Error cleaning cache."
        }
    }
}
