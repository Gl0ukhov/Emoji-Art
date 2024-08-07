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
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var background: URL? {
        emojiArt.background
    }
    
    func setBaclground(_ url: URL?) {
        emojiArt.background = url
    }
    
    func addEmpoji(_ emoji: String, at position: Emoji.Position, size: CGFloat) {
        emojiArt.addEmpoji(emoji, at: position, size: Int(size))
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
}

extension EmojiArt.Emoji.Position {
    func in(_ geometry: GeometryProxy) -> CGPoint {
        
    }
}
