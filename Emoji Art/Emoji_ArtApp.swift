//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by Матвей Глухов on 07.08.2024.
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    @StateObject var defaultDocument = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(named: "Main")
    @StateObject var store2 = PaletteStore(named: "Alternative")
    @StateObject var store3 = PaletteStore(named: "Special")
    
    var body: some Scene {
        WindowGroup {
//            EmojiArtDocumentView(document: defaultDocument)
            PaletteManager(stores: [paletteStore, store2, store3], selectedStore: paletteStore)
                .environmentObject(paletteStore)
        }
    }
}
