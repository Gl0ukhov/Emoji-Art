//
//  Palette.swift
//  Emoji Art
//
//  Created by Матвей Глухов on 12.08.2024.
//

import Foundation

struct Palette: Identifiable, Codable, Hashable {
    var name: String
    var emojis: String
    
    var id = UUID()
    
    static var builtins: [Palette] { [
        Palette(name: "Vehicles", emojis:
                    "🚕🚗🚙🚌🏎️"),
        Palette(name: "Sports", emojis:
                    "⚽️🏀🏈⚾️🥎"),
        Palette(name: "Music", emojis:
                    "🎹🎼🎤🥁")
    ] }
}
