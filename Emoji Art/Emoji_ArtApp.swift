//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by Матвей Глухов on 07.08.2024.
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    @State var defaultDocument = EmojiArtDocument()
    @State var paletteStore = PaletteStore(named: "Main")
    @State var store2 = PaletteStore(named: "Alternative")
    @State var store3 = PaletteStore(named: "Special")
    
    var body: some Scene {
        WindowGroup {
//            EmojiArtDocumentView(document: defaultDocument)
            PaletteManager(stores: [paletteStore, store2, store3], selectedStore: paletteStore)
                .environment(paletteStore)
        }
    }
}
