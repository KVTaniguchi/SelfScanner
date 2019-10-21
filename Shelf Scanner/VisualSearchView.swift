//
//  VisualSearchView.swift
//  Shelf Scanner
//
//  Created by Kevin Taniguchi on 10/20/19.
//  Copyright © 2019 Kevin Taniguchi. All rights reserved.
//

import Combine
import SwiftUI

struct VisualSearchView: View {
    let searchTerm: String
    
    init(searchTerm: String) {
        self.searchTerm = searchTerm
    }
    
    var body: some View {
        ViewPort()
    }
}

struct VisualSearchView_Previews: PreviewProvider {
    static var previews: some View {
        VisualSearchView(searchTerm: "")
    }
}
