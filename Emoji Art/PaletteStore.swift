//
//  PaletteStore.swift
//  Emoji Art
//
//  Created by Матвей Глухов on 12.08.2024.
//

import SwiftUI

@Observable
class PaletteStore {
    let name: String
    var palettes: [Palette] {
        didSet {
            if pa
        }
    }
    
    init(named name: String) {
        self.name = name
        palettes = Palette.builtins
        if palettes.isEmpty {
            palettes = [Palette(name: "Warning", emojis: "⚠️")]
        }
    }
}
