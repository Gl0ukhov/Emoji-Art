//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Матвей Глухов on 07.08.2024.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    var document: EmojiArtDocument
    
    private let emojis = "💏👩‍❤️‍💋‍👨💑👩‍❤️‍👨💌💘💝💖💗💓💞💕💟❣️💔❤️‍🔥❤️‍🩹❤️🩷🧡💛💚💙🩵💜🤎🖤🩶🤍😀😃😄😁😆😅🤣😂🙂🙃🫠😉😊😇🥰😍🤩😘😗☺️😚😙🥲😋😛😜🤪😝🤑🤗🤭🫢🫣🤫🤔🫡🤐🤨😐😑😶🫥😶‍🌫️😏😒🙄😬😮‍💨🤥🫨😌😔😪🤤😴😷🤒🤕🤢🤮🤧🥵🥶🥴😵😵‍💫🤯🤠🥳🥸😎🤓🧐😕🫤😟🙁☹️😮😯😲😳🥺🥹😦😧😨😰😥😢😭😱😖😣😞😓😩😫🥱😤😡😠🤬😈👿💀☠️💩🤡👹👺👻👽👾🤖😺😸😹😻😼😽🙀😿😾🙈🙉🙊💋💯💢💥💫💦💨🕳️💤👋🤚🖐️✋🖖🫱🫲🫳🫴🫷🫸👌🤌🤏✌️🤞🫰🤟🤘🤙👈👉👆🖕👇☝️🫵👍👎✊👊🤛🤜👏"
    
    private let paletteEmojiSize: CGFloat = 50
    
    // Набор выбранных эмодзи
    @State private var selectedSetEmoji: Set<Emoji.ID> = []
    
    // Функция, которая проверяет выбран ли эмодзи
    private func emojiContain(_ emoji: Emoji.ID) -> Bool {
        selectedSetEmoji.contains(emoji)
    }
    
    // Функция выбора эмодзи
    private func emojiSelect(_ emoji: Emoji.ID) {
        if selectedSetEmoji.contains(emoji) {
            selectedSetEmoji.remove(emoji)
        } else {
            selectedSetEmoji.insert(emoji)
        }
    }
    
    // Функция для полного снятия выбора со всех эмодзи
    private func emojiAllRemoveSelect() {
        selectedSetEmoji.removeAll()
    }
   
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                drop(sturldatas, at: location, in: geometry)
            }
        }
    }
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    @State private var panEmoji: CGOffset = .zero
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    @GestureState private var gesturePanEmoji: CGOffset = .zero
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom, body: { value, gestureZoom, _ in
                gestureZoom = value
            })
            .onEnded { value in
                zoom *= value
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan, body: { value, gesturePan, _ in
                gesturePan = value.translation
                
            })
            .onEnded { value in
                pan += value.translation
                
            }
    }
    
    
    private var emojiPanGesture: some Gesture {
        DragGesture()
            .updating($gesturePanEmoji, body: { value, gesturePanEmoji, _ in
                gesturePanEmoji = value.translation
            })
            .onEnded { value in
                panEmoji += value.translation
            }
    }
    
    
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background)
            .position(Emoji.Position.zero.in(geometry, gesture: nil))
            .onTapGesture {
                emojiAllRemoveSelect()
            }
        ForEach(document.emojis) { emoji in
            Text(emoji.string)
                .font(emoji.font)
                .shadow(radius: emojiContain(emoji.id) ? 10 : 0)
                .position(emoji.position.in(geometry, gesture: gesturePanEmoji + panEmoji))
                .onTapGesture {
                    emojiSelect(emoji.id)
                }
                .gesture(emojiContain(emoji.id) ? emojiPanGesture : nil)

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
}



#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environment(PaletteStore(named: "Preview"))
}
