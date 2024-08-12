//
//  PaletteChooser.swift
//  Emoji Art
//
//  Created by Матвей Глухов on 12.08.2024.
//

import SwiftUI

struct PaletteChooser: View {
    @Environment (PaletteStore.self) var store
    
    var body: some View {
        HStack {
            chooser
            view(for: store.palettes[store.cursorIndex])
        }
    }
    
    var chooser: some View {
        Button {
            
        } label: {
            Image(systemName: "paintpalette")
        }
    }
    
    func view(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojiss(palette.emojis)
        }
    }
}

#Preview {
    PaletteChooser()
        .environment(PaletteStore(named: "Preview"))
}
