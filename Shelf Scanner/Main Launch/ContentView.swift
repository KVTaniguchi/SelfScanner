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
    @State var searchTerm: String = ""
    @State var showModal = false
 
    var body: some View {
        NavigationView {
            VStack {
                // text field with clear button
                TextField("Enter Search Term", text: $searchTerm)
                Button("Show Modal") {
                    self.showModal.toggle()
                }.sheet(isPresented: $showModal) {
                    VisualSearchView(searchTerm: self.searchTerm)
                }
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
