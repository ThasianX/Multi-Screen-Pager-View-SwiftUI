// Kevin Li - 10:44 AM - 5/31/20

import SwiftUI

struct ContentView: View {
    var body: some View {
        PagerView(
            pages: (0..<4).map {
                index in Page()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
