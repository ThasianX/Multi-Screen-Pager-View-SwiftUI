// Kevin Li - 10:44 AM - 5/31/20

import Foundation
import SwiftUI

let screen = UIScreen.main.bounds

struct Page: View {

    let color: Color

    var body: some View {
        ZStack {
            color
            VStack(spacing: 0) {
                Text("Page")
                Text("Page")
                Text("Page")
                Text("Page")
                Text("Page")
                Text("Page")
                Text("Page")
                Text("Page")
                Text("Page")
                Text("Page")
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct MultiTransformationPagerView<Content: View>: View {

    @State private var currentPageIndex: Int = 1
    @GestureState private var translation: CGFloat = .zero

    let pages: [Content]

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(0..<3) { i in
                    self.pages[i]
                        .frame(width: geometry.size.width)
                }
            }
            // The alignment property here is crucial because we are telling the geometry
            // reader to layout the HStack starting from left. As a result, the middle page
            // is initially shown. If you try any other alignment, you'll notice that the initial
            // setup of the HStack is wrong.
            // The alignment property also influences the scroll direction. By laying out our
            // pages left to right, we are specifying that to get to the next page, the user has
            // to scroll in the leftward direction.
            .frame(width: geometry.size.width, alignment: .leading)
            // Accounts for the initial offset position that shows the middle page first
            // Also accounts for subsequent page turns that change `currentIndex`
            .offset(x: -CGFloat(self.currentPageIndex) * geometry.size.width)
            // Accounts for user swipe gesture to go to a different page
            .offset(x: self.translation)
            .animation(.interactiveSpring())
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    // `state` is just a reference to `$translation`
                    // `value` refers to the current data for the drag
                    state = value.translation.width
                }.onEnded { value in
                    let pageTurnFraction = value.translation.width / geometry.size.width
                    // If the user has turned the page more than halfway, in which case
                    // `pageTurnFraction` > .5, we want to set the page that is being
                    // turned to as the new active page
                    let newIndex = Int((CGFloat(self.currentPageIndex) - pageTurnFraction).rounded())
                    // we don't want the index to be greater than 2 or less than 0
                    self.currentPageIndex = min(max(newIndex, 0), 2)
                }
            )
        }
    }

}

struct MultiTransformationPagerView_Previews: PreviewProvider {
    static var previews: some View {
        MultiTransformationPagerView(pages: [Page(color: getRandomColor()), Page(color: getRandomColor()), Page(color: getRandomColor())])
            .colorScheme(.dark)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
