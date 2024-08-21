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
    
    private var emojiArt = EmojiArt() {
        didSet {
            autosave()
        }
    }
    
    private let autosaveURL: URL = URL.documentsDirectory.appendingPathComponent("Autosaved.emojiart")
    
    private func autosave() {
        save(to: autosaveURL)
        print("autosaved to \(autosaveURL)")
    }
    
    private func save(to url: URL) {
        do {
            let data = try emojiArt.json()
            try data.write(to: url)
        } catch let error {
            print("EmojiArtDocument: error while saving \(error.localizedDescription)")
        }
    }
    
    init() {
        if let data = try? Data(contentsOf: autosaveURL),
           let autosavedEmojiArt = try? EmojiArt(json: data) {
            emojiArt = autosavedEmojiArt
        }
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
    
    func changePositionEmoji(emoji: Emoji.ID, offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(emojiID: emoji) {
            emojiArt.changePosition(emojiIndex: index, by: offset)
        }
    }
    
    func changeZoomEmoji(emoji: Emoji.ID, zoom: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(emojiID: emoji) {
            emojiArt.changeZoom(emojiIndex: index, zoom: zoom)
        }
    }
    
    func deleteEmoji(emoji: Emoji.ID) {
        emojiArt.deleteEmoji(emoji)
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
        return CGPoint(
            x: center.x + CGFloat(x) ,
            y: center.y - CGFloat(y))
    }
}



