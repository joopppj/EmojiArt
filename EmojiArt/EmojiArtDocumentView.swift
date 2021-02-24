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
    
    @State private var chosenPalette: String = ""
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(chosenPalette: $chosenPalette, document: document)
                ScrollView(.horizontal){
                    HStack {
                        ForEach(chosenPalette.map { String($0)}, id: \.self ){ emoji in
                            Text(emoji)
                                .font(Font.system(size: self.defaultEmojiSize))
                                .onDrag{ NSItemProvider(object: emoji as NSString)}
                        }
                    }
                }
                .onAppear{self.chosenPalette = self.document.defaultPalette}
            }
            
            GeometryReader { geometry in
                ZStack {
                    Color.yellow.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(self.panOffset)
                    )
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                    if self.isLoading {
                        Image(systemName: "timer").imageScale(.large).spinning()
                        }else{
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * self.zoomScale)
                                .position(self.position(for: emoji, in: geometry.size))
                            }
                    }
                }.clipped()
                    .gesture(self.panGesture())
                    .gesture(self.zoomGesture())
                    .edgesIgnoringSafeArea([.horizontal,.bottom])
                    .onReceive(self.document.$backgroundImage) { image in
                        self.zoomToFit(image, in: geometry.size)
                    }
                    .onDrop(of: ["public.image", "public.text"], isTargeted: nil){ providers, location in
                        var location = geometry.convert(location, from:.global)
                        location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                        location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                        location = CGPoint(x: location.x/self.zoomScale, y: location.y/self.zoomScale)
                        return self.drop(providers: providers, at: location)
                }
            }
            
        }
    }
    
    var isLoading: Bool {
        document.backgroundURL != nil  && document.backgroundImage == nil
    }
    
    
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0// updating state
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture()-> some Gesture{   // when we zoom in or zoom out
        MagnificationGesture()
            .updating($gestureZoomScale){ latestGestureScale, ourGestureStateInOut, transaction in
                ourGestureStateInOut = latestGestureScale
            }
            .onEnded{ finalGestureScale in
                self.steadyStateZoomScale *= finalGestureScale
            }
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset){ latestDragGestureValue, GesturePanOffset, transaction in
                GesturePanOffset = latestDragGestureValue.translation / self.zoomScale
            }
        .onEnded { finalDragGestureValue in
            self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation/self.zoomScale)
        }
    }
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count:2)
            .onEnded{
                withAnimation{
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0 ,image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.steadyStatePanOffset = CGSize.zero
            self.steadyStateZoomScale = min(hZoom,vZoom)
        }
    }
    
    
    private func position(for emoji: EmojiArt.Emoji, in size:CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: emoji.location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
        //CGPoint(x: emoji.location.x + size.width/2, y: emoji.location.y + size.height/2)
    }
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self){ url in // if it is url dropping
            //print("dropped \(url)")
            self.document.backgroundURL = url
        }
        if !found { // if it is text dropping
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}





