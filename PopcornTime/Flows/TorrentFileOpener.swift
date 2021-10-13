//
//  TorrentFileOpener.swift
//  TorrentFileOpener
//
//  Created by Alexandru Tudose on 10.10.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI

struct OpenCommand: Commands {
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            TorrentFileOpener()
        }
    }
}

struct TorrentFileOpener: View {
    @State var showFileImporter = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button("Open Torrent...") {
            showFileImporter = true
        }
        .keyboardShortcut("O", modifiers: .command)
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.types(tag: "torrent", tagClass: .filenameExtension, conformingTo: nil).first!]) { result in
            if let url = try? result.get() {
                openURL(url)
            }
            print(result)
        }
        
    }
}

struct TorrentFileOpener_Previews: PreviewProvider {
    static var previews: some View {
        TorrentFileOpener()
    }
}
