//
//  ContentView.swift
//  Shelf Scanner
//
//  Created by Kevin Taniguchi on 10/4/19.
//  Copyright © 2019 Kevin Taniguchi. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView : View {
    let viewPort: ViewPort
    @ObservedObject var watcher = Watcher(text: "Watch my value change")
    
    init() {
        
        let recognizedText: RecognizedText = RecognizedText(value: "Point me at a shelf")
        viewPort = ViewPort(recognizedText: recognizedText)
        
        let subscriber = Subscribers.Assign(object: watcher, keyPath: \.text)

        let publisher = recognizedText.objectWillChange.receive(on: DispatchQueue.main)
        
        let converter = Publishers.Map(upstream: publisher) { _ in
            recognizedText.value
        }
        
        converter.subscribe(subscriber)
    }
 
    var body: some View {
        NavigationView {
            VStack {
                Text(watcher.text)
                viewPort
            }
        }   
    }
}

// this will be fleshed out into a class that represents each item on the shelf
class Watcher: ObservableObject {
    @Published var text: String
    
    init(text: String) {
        self.text = text
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
