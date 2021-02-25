//
//  Grid.swift
//  Memorize
//
//  Created by キラ on 2021/02/02.
//  Copyright © 2021 Kira. All rights reserved.
//  this is stock we created

import SwiftUI

extension Grid where Item: Identifiable , ID == Item.ID {
    init(_ items: [Item], viewForItem: @escaping (Item) -> ItemView) {
        self.init(items, id: \Item.id, viewForItem: viewForItem)
    }
}

struct Grid<Item,ID, ItemView>: View where ID: Hashable, ItemView: View{
    var items: [Item]
    private var id: KeyPath<Item, ID>
    var viewForItem:(Item) -> ItemView
    
    init(_ items: [Item], id: KeyPath<Item,ID>, viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.id = id
        self.viewForItem = viewForItem
    }
    var body: some View {
        GeometryReader { geometry in
            self.body(for: GridLayout(itemCount: self.items.count, in: geometry.size))
        }
    }
    
    
    private func body(for layout: GridLayout) -> some View{
        ForEach(items, id: id){ item in
            self.body(for: item, in: layout)
           
        }
    }
    
   private  func body(for item: Item, in layout: GridLayout) -> some View {
    let index = items.firstIndex(where: { item[keyPath: id] == $0[keyPath: id] } )
        
    return Group {
        if index != nil {
        viewForItem(item)
            .frame(width: layout.itemSize.width, height: layout.itemSize.height) //create the frame of card
            .position(layout.location(ofItemAt: index!)) // put card in correct position
        }
    }
    }
}



