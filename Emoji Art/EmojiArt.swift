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
    
    mutating func changePosition(emojiIndex: Int, by offset: CGSize) {
        emojis[emojiIndex].position.x += Int(offset.width)
        emojis[emojiIndex].position.y -= Int(offset.height)
    }
    
    mutating func changeZoom(emojiIndex: Int, zoom: CGFloat) {
        emojis[emojiIndex].size = Int(CGFloat(emojis[emojiIndex].size) * zoom)
        
        
    }
    
    mutating func deleteEmoji(_ emoji: Emoji.ID) {
        if let index = emojis.firstIndex(emojiID: emoji) {
            emojis.remove(at: index)
        }
    }
    
    struct Emoji: Identifiable {
        let string: String
        var position: Position
        var size: Int
        var id: Int
        
        struct Position {
            var x: Int
            var y: Int
            
            static let zero = Self(x: 0, y: 0)
        }
    }
}
