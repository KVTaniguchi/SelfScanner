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
    @ObservedObject var recognizedText: RecognizedText = RecognizedText()
 
    var body: some View {
        NavigationView {
            VStack {
                Text(recognizedText.value)
                NavigationLink(destination: ViewPort(recognizedText: $recognizedText.value)) {
                    Text("Scanner")
                }
            }
        }   
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
