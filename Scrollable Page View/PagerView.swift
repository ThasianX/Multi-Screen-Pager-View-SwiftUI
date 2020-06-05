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
    }
}

fileprivate let deltaCutoff: CGFloat = 0.7

fileprivate let centerMinRadius: CGFloat = 0
fileprivate let centerCutoffRadius: CGFloat = 40
fileprivate let centerMaxRadius: CGFloat = centerMinRadius + centerCutoffRadius

fileprivate let centerMaxHeight = screen.height
fileprivate let centerCutoffHeight: CGFloat = 150
fileprivate let centerMinHeight: CGFloat = centerMaxHeight - centerCutoffHeight

struct MultiTransformationPagerView<Content: View>: View {

    @State private var currentPageIndex: Int = 1
    @GestureState private var translation: CGFloat = .zero

    let pages: [Content]

    private func pageTurnDelta(pageWidth: CGFloat) -> CGFloat {
        translation / pageWidth
    }

    private func centerCornerRadius(pageWidth: CGFloat) -> CGFloat {
        // Corner radius should only start being modified for the center and last page
        guard currentPageIndex != 0 else { return centerMinRadius }

        // We want to see how far we've swiped
        let delta = pageTurnDelta(pageWidth: pageWidth)

        // This means we're swiping left
        if delta < 0 {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, we don't want the center page's radius to change.
            guard currentPageIndex == 1 else { return centerMaxRadius }
            // Now we know we're on the center page and we're swiping towards the last page,
            // we don't want to add too much to the center radius
            guard abs(delta) <= deltaCutoff else { return centerMaxRadius }

            let radiusToBeAdded = delta * (centerCutoffRadius / 0.7) // negative
            return centerMinRadius - radiusToBeAdded
        } else if delta > 0 {
            // If we're swiping from the center page towards the first page, we don't
            // want any radius changes to the center page
            guard currentPageIndex == 2 else { return centerMinRadius }
            // Once the center page's radius gets restored to its initial radius, we don't
            // want to keep subtracting from its radius
            guard abs(delta) <= deltaCutoff else { return centerMinRadius }

            let radiusToBeSubtracted = delta * (centerCutoffRadius / 0.7)
            return centerMaxRadius - radiusToBeSubtracted
        } else {
            // When the user isn't dragging anything and the center page is active,
            // we don't want there to be any radius. But when the last page is active,
            // and there is no drag translation, we want the center page's radius to be at its max
            return currentPageIndex == 1 ? centerMinRadius : centerMaxRadius
        }
    }

    private func centerPageHeight(pageWidth: CGFloat) -> CGFloat? {
        // Center page's height should only be modified for the center and last page
        guard currentPageIndex != 0 else { return nil }

        // We want to see how far we've swiped
        let delta = pageTurnDelta(pageWidth: pageWidth)

        // This means we're swiping left
        if delta < 0 {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, we don't want the center page's height to change.
            guard currentPageIndex == 1 else { return centerMinHeight }
            // Now we know we're on the center page and we're swiping towards the last page,
            // we don't want to cut off too much of the height
            guard abs(delta) <= deltaCutoff else { return centerMinHeight }

            let heightToBeCutoff = delta * (centerCutoffHeight / 0.7) // negative
            return centerMaxHeight + heightToBeCutoff
        } else if delta > 0 {
            // If we're swiping from the center page towards the first page, we don't
            // want any height changes to the center page
            guard currentPageIndex == 2 else { return nil }
            // Once the center page's height gets restored to its initial height, we don't
            // want to keep adding to its height and make it greater than the screen's height
            guard abs(delta) <= deltaCutoff else { return nil }

            let heightToBeAdded = delta * (centerCutoffHeight / 0.7)
            return centerMinHeight + heightToBeAdded
        } else {
            // When the user isn't dragging anything, we want the center page to be fullscreen
            // when its active but at its min height when the last page is active
            return currentPageIndex == 1 ? nil : centerMinHeight
        }
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(0..<3) { i in
                    self.pages[i]
                        .frame(width: geometry.size.width)
                        .clipShape(RoundedRectangle(cornerRadius: i == 1 ? self.centerCornerRadius(pageWidth: geometry.size.width) : 0, style: .continuous))
                        .frame(height: i == 1 ? self.centerPageHeight(pageWidth: geometry.size.width) : nil)

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
            .edgesIgnoringSafeArea(.all)
            .colorScheme(.dark)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}