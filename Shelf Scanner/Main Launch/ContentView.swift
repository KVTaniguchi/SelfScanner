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
        ZStack {
            Color.gray
            .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 20.0, content: {
                TextField("Enter Search Term", text: $searchTerm).accentColor(.green).padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 50))
                Button("Search") {
                    self.showModal.toggle()
                }.sheet(isPresented: $showModal) {
                    VisualSearchView(searchTerm: self.searchTerm)
                }
            }).padding(.horizontal, 60)
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
