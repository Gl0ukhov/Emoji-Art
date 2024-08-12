//
//  Palette.swift
//  Emoji Art
//
//  Created by Матвей Глухов on 12.08.2024.
//

import Foundation

struct Palette: Identifiable {
    var name: String
    var emojis: String
    
    let id = UUID()
    
    static let builtins = [
        Palette(name: "Vehicles", emojis:
                    "🚕🚗🚙🚌🏎️"),
        Palette(name: "Sports", emojis:
                    "⚽️🏀🏈⚾️🥎"),
        Palette(name: "Music", emojis:
                    "🎹🎼🎤🥁")
    ]
}
