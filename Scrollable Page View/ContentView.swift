// Kevin Li - 10:44 AM - 5/31/20

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        MultiTransformationPagerView(pages: [Page(color: .orange), Page(color: .green), Page(color: .clear)])
            .edgesIgnoringSafeArea(.all)
    }

}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }

}
