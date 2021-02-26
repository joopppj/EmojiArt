//
//  EmojiArtDocumentChooser.swift
//  EmojiArt
//
//  Created by キラ on 2/26/21.
//  Copyright © 2021 Kira. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentChooser: View {
    
    @EnvironmentObject var store: EmojiArtDocumentStore
    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    NavigationLink(destination: EmojiArtDocumentView(document: document)
                        .navigationBarTitle(self.store.name(for: document))
                    ){
                        Text("Hello, World!")
                        }
                }
            }
            .navigationBarTitle(self.store.name)
            .navigationBarItems(leading: Button(
                action: { self.store.addDocument()},
                label: {Image(systemName: "plus").imageScale(.large)
            }))
        }
    }
}

struct EmojiArtDocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChooser()
    }
}
