//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Матвей Глухов on 07.08.2024.
//

import SwiftUI

@Observable
class EmojiArtDocument {
    typealias Emoji = EmojiArt.Emoji
    
    private var emojiArt = EmojiArt()
    
    
    init() {
        emojiArt.addEmoji("🚑", at: .init(x: 100, y: -80), size: 200)
        emojiArt.addEmoji("🦆", at: .init(x: 250, y: 100), size: 80)
    }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var background: URL? {
        emojiArt.background
    }
    
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat) {
        emojiArt.addEmoji(emoji, at: position, size: Int(size))
    }
    
    func selectionEmoji(_ emoji: Emoji) {
        emojiArt.selectEmoji(emoji)
    }
    
    func removeSelection() {
        emojiArt.removeSelection()
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}
