//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by キラ on 2/23/21.
//  Copyright © 2021 Kira. All rights reserved.
//

import SwiftUI

struct PaletteChooser: View {
    @Binding var chosenPalette: String 
    
    @ObservedObject var document: EmojiArtDocument
    var body: some View {
        HStack{
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: { Text("")})
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(chosenPalette: Binding.constant(""), document: EmojiArtDocument())
    }
}
