//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by キラ on 2/17/21.
//  Copyright © 2021 Kira. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    var body: some View {
        HStack {
            ForEach(EmojiArtDocument.palette.map { String($0)}, id: \.self ){ emoji in
                Text(emoji)
                    .font(Font.system(size: self.defaultEmojiSize))
            }
        }
        
    }
    
    private let defaultEmojiSize: CGFloat = 40
}
