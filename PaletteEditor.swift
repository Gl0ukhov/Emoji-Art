//
//  PaletteEditor.swift
//  Emoji Art
//
//  Created by Матвей Глухов on 21.08.2024.
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette: Palette
    
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $palette.name)
                    .font(Font.system(size: 30))
            } header: {
                Text("Name")
                    .font(.subheadline)
            }
            
            Section {
                Text("Add Emojis Here")
                removeEmojis
            } header: {
                Text("Add Emojis Here")
                    .font(.subheadline)
            }
        }
    }
    
    var removeEmojis: some View {
        VStack(alignment: .trailing) {
            Text("Tap to Remove Emojis")
                .font(.caption)
                .foregroundStyle(.gray)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self ) { emoji in
                    Text(emoji)
                }
            }
        }
    }
}

//#Preview {
//    PaletteEditor()
//}
