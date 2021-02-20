//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by キラ on 2/19/21.
//  Copyright © 2021 Kira. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    
    var uiImage : UIImage?
    
    var body:some View{
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)//.resizable()
            }
        }
    }
    
    
}
