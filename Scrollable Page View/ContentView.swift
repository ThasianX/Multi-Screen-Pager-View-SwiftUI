// Kevin Li - 10:44 AM - 5/31/20

import SwiftUI

struct ContentView: View {
    var body: some View {
        MultiTransformationPagerView(pages: [Page(color: getRandomColor()), Page(color: getRandomColor()), Page(color: getRandomColor())])
            .edgesIgnoringSafeArea(.all)
    }
}

func getRandomColor() -> Color {
    let r = Double.random(in: 0..<1)
    let g = Double.random(in: 0..<1)
    let b = Double.random(in: 0..<1)
    return Color(red: r, green: g, blue: b, opacity: 1.0)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
