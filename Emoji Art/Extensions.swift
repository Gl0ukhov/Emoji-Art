//
//  Extension.swift
//  Emoji Art
//
//  Created by CS193p Instructor on 5/8/23.
//  Copyright (c) 2023 Stanford University
//

import SwiftUI

typealias CGOffset = CGSize

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x-size.width/2, y: center.y-size.height/2), size: size)
    }
}

extension CGOffset {
    static func +(lhs: CGOffset, rhs: CGOffset) -> CGOffset {
        CGOffset(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func +=(lhs: inout CGOffset, rhs: CGOffset) {
        lhs = lhs + rhs
    }
}

extension String {
    var uniqued: String {
        reduce(into: "") { sofar, element in
            if !sofar.contains(element) {
                sofar.append(element)
            }
        }
    }
}

extension Collection where Element: Identifiable {
    func firstIndex(emojiID: Element.ID) -> Self.Index? {
        firstIndex(where: { $0.id == emojiID } )
    }
}

extension AnyTransition {
    static let rollUp: AnyTransition = .asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top))
    static let rollDown: AnyTransition = .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom))
}

struct AnimatedActionButton: View {
    var title: String? = nil
    var systemImage: String? = nil
    var role: ButtonRole?
    let action: () -> Void
    
    init(_ title: String? = nil,
         systemImage: String? = nil,
         role: ButtonRole? = nil,
         action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(role: role) {
            withAnimation {
                action()
            }
        } label: {
            if let title, let systemImage {
                Label(title, systemImage: systemImage)
            } else if let title {
                Text(title)
            } else if let systemImage {
                Image(systemName: systemImage)
            }
        }
    }
}

extension Character {
    var isEmoji: Bool {
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        } else {
            return false
        }
    }
}

extension String {
    mutating func remove(_ ch: Character) {
        removeAll(where: { $0 == ch })
    }
}

struct UndoButton: View {
    @Environment(\.undoManager) var undoManager
    
    @State private var showUndoMenu = false
    
    var body: some View {
        if let undoManager {
            Image(systemName: "arrow.uturn.backward.circle")
                .foregroundColor(.accentColor)
                .onTapGesture {
                    undoManager.undo()
                }
                .onLongPressGesture(minimumDuration: 0.05) {
                    showUndoMenu = true
                }
                .popover(isPresented: $showUndoMenu) {
                    VStack {
                        if !undoManager.canUndo, !undoManager.canRedo {
                            Text("Nothing to Undo")
                        } else {
                            if undoManager.canUndo {
                                Button("Undo " + undoManager.undoActionName) {
                                    undoManager.undo()
                                    showUndoMenu = false
                                }
                            }
                            if undoManager.canRedo {
                                if undoManager.canUndo {
                                    Divider()
                                }
                                Button("Redo " + undoManager.redoActionName) {
                                    undoManager.redo()
                                    showUndoMenu = false
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: 280)
                }
        }
    }
}

extension View {
    @ViewBuilder
    func wrappedInNavigationViewToMakeDismissable(_ dismiss: (() -> Void)?) -> some View {
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
            NavigationStack {
                self
                    .navigationBarTitleDisplayMode(.inline)
                    .dismissable(dismiss)
            }
        } else {
            self
        }
    }
    
    
    @ViewBuilder
    func dismissable(_ dismiss: (() -> Void)?) -> some View {
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
            self.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }, label: {
                        Text("Close")
                            .font(.callout)
                    })
                }
            }
        } else {
            self
        }
    }
}
