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
    
    @State private var showPaletteEditor = false
    
    var body: some View {
        HStack{
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: { Text("")})
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    self.showPaletteEditor = true
            }
                .sheet(isPresented: $showPaletteEditor){
                    PaletteEditor(chosenPalette: self.$chosenPalette, isShowing: self.$showPaletteEditor)
                        .environmentObject(self.document)
                        .frame(minWidth: 300, minHeight: 500)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteEditor: View { // popover
    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @Binding var isShowing: Bool
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    var body: some View{
        VStack(spacing:0){
            ZStack{
                Text("Editor").font(.headline).padding()
                HStack {
                    Spacer()
                    Button(action: {self.isShowing = false}, label: { Text("Done")  }).padding()
                    }
            }
                Divider()
            Form{
                Section{
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began{
                            self.document.renamePalette(self.chosenPalette, to: self.paletteName)
                        }
                    })
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began{
                            self.chosenPalette = self.document.addEmoji(self.emojisToAdd, toPalette: self.chosenPalette)
                            self.emojisToAdd = ""
                        }
                    })
                }
                Section(header: Text("Remove Emoji")){
                    
                    Grid(chosenPalette.map{ String($0) }, id: \.self) { emoji in
                        Text(emoji).font(Font.system(size: self.fontSize))
                                .onTapGesture {
                                    self.chosenPalette = self.document.removeEmoji(emoji, fromPalette: self.chosenPalette)
                            }
                    }
                    .frame(height: self.height)
                }
            }
        }
        .onAppear{ self.paletteName = self.document.paletteNames[self.chosenPalette] ?? "" }
    }
    var height: CGFloat {
        CGFloat(((chosenPalette.count-1)/6)*70 + 70)
    }
    
    let fontSize: CGFloat = 40
    
    
}


struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(chosenPalette: Binding.constant(""), document: EmojiArtDocument())
    }
}
