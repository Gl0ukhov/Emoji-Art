//
//  EmojiArt.swift
//  Emoji Art
//
//  Created by Матвей Глухов on 07.08.2024.
//

import Foundation

struct EmojiArt {
    
    var background: URL?
    private(set) var emojis = [Emoji]()
    
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(
            string: emoji,
            position: position,
            size: size,
            id: uniqueEmojiId))
    }
    
    mutating func removeSelection() {
        for i in emojis.indices {
            emojis[i].selection = false
        }
    }
    
    mutating func selectEmoji(_ emoji: EmojiArt.Emoji) {
        let index = emojis.firstIndex { $0.id == emoji.id }
        if let index {
            emojis[index].selection.toggle()
        }
    }
    
    struct Emoji: Identifiable {
        let string: String
        var position: Position
        var size: Int
        var id: Int
        var selection = false 
        
        struct Position {
            var x: Int
            var y: Int 
            
            static let zero = Self(x: 0, y: 0)
        }
    }
}
