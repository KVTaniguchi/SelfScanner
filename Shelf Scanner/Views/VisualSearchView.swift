import Combine
import SwiftUI

struct VisualSearchView: View {
    let searchTerm: String
    
    init(searchTerm: String) {
        self.searchTerm = searchTerm
    }
    
    var body: some View {
        ViewPort(searchTerm: searchTerm)
    }
}

struct VisualSearchView_Previews: PreviewProvider {
    static var previews: some View {
        VisualSearchView(searchTerm: "")
    }
}
