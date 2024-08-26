//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Матвей Глухов on 07.08.2024.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    @ObservedObject var document: EmojiArtDocument
    
    // MARK: General properties
    @State private var notificationOfDeletion = false
    private let paletteEmojiSize: CGFloat = 50 
    
    // MARK: Main screen
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    // MARK: Drawing window
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(selectedSetEmoji.isEmpty ? zoom * gestureZoom : zoom)
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                drop(sturldatas, at: location, in: geometry)
            }
            .onTapGesture {
                emojiAllRemoveSelect()
            }
        }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background) { phase in
            if let image = phase.image {
                image
            } else if let url = document.background {
                if phase.error != nil {
                    Text("\(url)")
                } else {
                    ProgressView()
                }
            }
        }
            .position(Emoji.Position.zero.in(geometry))
        ForEach(document.emojis) { emoji in
            Text(emoji.string)
                .font(emoji.font)
                .shadow(color: .red, radius: emojiContain(emoji.id) ? 10 : 0)
                .position(emoji.position.in(geometry))
                .scaleEffect(emojiContain(emoji.id) ? gestureZoom : 1)
                .onTapGesture {
                    emojiSelect(emoji.id)
                }
                .offset(emojiContain(emoji.id) ? panEmoji + gesturePanEmoji : .zero)
                .gesture(emojiPanGesture(emoji))
                .alert(selectedSetEmoji.isEmpty ? "Select the emoji to delete" : "Delete \(selectedSetEmoji.count) emojis?", isPresented: $notificationOfDeletion, actions: {
                    if !selectedSetEmoji.isEmpty {
                        Button("Delete", role: .destructive) {
                            for emojiID in selectedSetEmoji {
                                document.deleteEmoji(emoji: emojiID)
                            }
                            emojiAllRemoveSelect()
                        }
                    }
                })
        }
    }
    
    private func drop(_ sturldatas: [Sturldata], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url)
                return true
            case .string(let emoji):
                document.addEmoji(
                    emoji,
                    at: emojiPosition(at: location, in: geometry),
                    size: paletteEmojiSize / zoom
                )
                return true
            default: break
            }
        }
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        return Emoji.Position(
            x: Int((location.x - center.x - pan.width ) / zoom),
            y: Int(-(location.y - center.y - pan.height ) / zoom)
        )
    }
    
    // MARK: Tap gesture
    @State private var selectedSetEmoji: Set<Emoji.ID> = []
    
    private func emojiContain(_ emoji: Emoji.ID) -> Bool {
        selectedSetEmoji.contains(emoji)
    }
    
    private func emojiSelect(_ emoji: Emoji.ID) {
        if selectedSetEmoji.contains(emoji) {
            selectedSetEmoji.remove(emoji)
        } else {
            selectedSetEmoji.insert(emoji)
        }
    }
    
    private func emojiAllRemoveSelect() {
        selectedSetEmoji.removeAll()
    }
    
    // MARK: General drag gesture
    @GestureState private var gesturePan: CGOffset = .zero
    @State private var pan: CGOffset = .zero
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan, body: { value, gesturePan, _ in
                gesturePan = value.translation
            })
            .onEnded { value in
                pan += value.translation
            }
    }
    
    // MARK: Drag gesture for emoji
    @GestureState private var gesturePanEmoji: CGOffset = .zero
    @State private var panEmoji: CGOffset = .zero
    
    private func emojiPanGesture(_ emoji: Emoji) -> some Gesture {
        DragGesture()
            .updating($gesturePanEmoji, body: { value, gesturePanEmoji, _ in
                if emojiContain(emoji.id) {
                    gesturePanEmoji = value.translation
                }
            })
            .onEnded { value in
                if emojiContain(emoji.id) {
                    for e in selectedSetEmoji {
                        document.changePositionEmoji(emoji: e, offset: value.translation)
                    }
                }
            }
    }
    
    // MARK: Zoom gesture
    @State private var zoom: CGFloat = 1
    @State private var zoomEmoji: CGFloat = 1
    
    @GestureState private var gestureZoom: CGFloat = 1
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom, body: { value, gestureZoom, _ in
                gestureZoom = value
            })
            .onEnded { value in
                if !selectedSetEmoji.isEmpty {
                    zoomEmoji *= value
                    for emojiID in selectedSetEmoji {
                        document.changeZoomEmoji(emoji: emojiID, zoom: zoomEmoji)
                    }
                    zoomEmoji = 1
                } else {
                    zoom *= value
                }
            }
    }
}



#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(named: "Preview"))
}
