//
//  ContentView.swift
//  Shelf Scanner
//
//  Created by Kevin Taniguchi on 10/4/19.
//  Copyright © 2019 Kevin Taniguchi. All rights reserved.
//

import SwiftUI
import Combine

//class Contact: ObservableObject {
//    @Published var name: String
//    @Published var age: Int
//
//    init(name: String, age: Int) {
//        self.name = name
//        self.age = age
//    }
//
//    func haveBirthday() -> Int {
//        age += 1
//        return age
//    }
//}
//
//let john = Contact(name: "John Appleseed", age: 24)
//john.objectWillChange.sink { _ in print("\(john.age) will change") }
//print(john.haveBirthday())

struct ContentView : View {
    let viewPort: ViewPort
    
    var watcher = Watcher(text: "Watch my value change")
    
    init() {
        let subscriber = Subscribers.Assign(object: watcher, keyPath: \.text)
        let recognizedText: RecognizedText = RecognizedText(value: "Point me at a shelf")
        viewPort = ViewPort(recognizedText: recognizedText)

        let publisher = recognizedText.objectWillChange
        
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

class Watcher {
    var text: String
    
    init(text: String) {
        self.text = text
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/// the view port is a subscriber?
