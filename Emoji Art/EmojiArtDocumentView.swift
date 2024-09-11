//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Матвей Глухов on 07.08.2024.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    @StateObject var paletteStore = PaletteStore(named: "Shared")
    
    @Environment(\.undoManager) var undoManager
    
    typealias Emoji = EmojiArt.Emoji
    @ObservedObject var document: EmojiArtDocument
    
    // MARK: General properties
    @State private var notificationOfDeletion = false
    @ScaledMetric private var paletteEmojiSize: CGFloat = 50
    
    
    // MARK: Main screen
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
        .toolbar {
            UndoButton()
//            AnimatedActionButton("Paste background", systemImage: "doc.on.clipboard") {
//                pasteBackground() 
//            }
            AnimatedActionButton("Camer", systemImage: "camera") {
                if Camera.isAvailable {
                    backgroundPicker = .camera
                }
            }
        }
        .sheet(item: $backgroundPicker, content: { pickerType in
            switch pickerType {
            case .camera: Camera { image in handlePickedBackgroundImage(image)}
            case .library: EmptyView()
            }
        })
        .environmentObject(paletteStore)
    }
    
    private func handlePickedBackgroundImage(_ image: UIImage?) {
        if let imageData = image?.jpegData(compressionQuality: 1.0) {
//            document.setBackground(URL?)
        }
        backgroundPicker = nil
    }
    
    @State private var backgroundPicker: BackgroundPickerType? = nil
    
    enum BackgroundPickerType: Identifiable {
        case camera
        case library
        var id: BackgroundPickerType { self }
    }
    
    private func pasteBackground() {
        if let imageData = UIPasteboard.general.image?.jpegData(compressionQuality: 1.0) {
            
        } else if let url = UIPasteboard.general.url?.imageURL {
            document.setBackground(url, undoWith: undoManager)
        } else {
            
        }
    }
    
    // MARK: Drawing window
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                if document.background.isFetching {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.blue)
                        .position(Emoji.Position.zero.in(geometry))
                }
                documentContents(in: geometry)
                    .scaleEffect(selectedSetEmoji.isEmpty ? zoom * gestureZoom : zoom)
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                drop(sturldatas, at: location, in: geometry)
            }
            .onTapGesture(count: 2, perform: {
                zoomToFit(document.bbox, in: geometry)
            })
            .onTapGesture(count: 1) {
                emojiAllRemoveSelect()
            }
            
            .onChange(of: document.background.failureReason) { _, reason in
                showBackgroundFailureAlert = (reason != nil)
            }
            .onChange(of: document.background.uiImage) { uiImage, _ in
                zoomToFit(uiImage?.size, in: geometry)
            }
            .alert(
                "Set Background",
                isPresented: $showBackgroundFailureAlert,
                presenting: document.background.failureReason,
                actions: { reason in
                    Button("OK", role: .cancel) { }
                },
                message: { reason in
                    Text(reason)
                }
            )
        }
    }
    
    private func zoomToFit(_ size: CGSize?, in geometry: GeometryProxy) {
        if let size {
            zoomToFit(CGRect(center: .zero, size: size), in: geometry)
        }
    }
    
    private func zoomToFit(_ rect: CGRect, in geometry: GeometryProxy) {
        withAnimation {
            if rect.size.width > 0, rect.size.height > 0,
               geometry.size.width > 0, geometry.size.height > 0 {
                let hZoom = geometry.size.width / rect.size.width
                let vZoom = geometry.size.height / rect.size.height
                zoom = min(hZoom, vZoom)
                pan = CGOffset(
                    width: -rect.midX * zoom,
                    height: -rect.midY * zoom
                )
            }
        }
    }
    
    @State private var showBackgroundFailureAlert = false
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        if let uiImage = document.background.uiImage {
            Image(uiImage: uiImage)
                .position(Emoji.Position.zero.in(geometry))
        }
        ForEach(document.emojis) { emoji in
            Text(emoji.string)
                .font(emoji.font)
                .shadow(color: .red, radius: emojiContain(emoji.id) ? 10 : 0)
                .position(emoji.position.in(geometry))
                .scaleEffect(emojiContain(emoji.id) ? gestureZoom : 1)
                .onTapGesture(count: 1) {
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
                document.setBackground(url, undoWith: undoManager)
                return true
            case .string(let emoji):
                document.addEmoji(
                    emoji,
                    at: emojiPosition(at: location, in: geometry),
                    size: paletteEmojiSize / zoom,
                    undoWith: undoManager
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
