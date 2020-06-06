// Kevin Li - 10:44 AM - 5/31/20

import Foundation
import SwiftUI

let screen = UIScreen.main.bounds

struct SidePage: View {

    @EnvironmentObject var pagerState: PagerState

    var body: some View {
        ZStack(alignment: .leading) {
            Color.orange
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
            .font(.title)
        }
        .contentShape(Rectangle())
    }

}

struct CenterPage: View {

    @EnvironmentObject var pagerState: PagerState

    var body: some View {
        ZStack(alignment: .leading) {
            Color.green
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
            .font(.title)
        }
        .contentShape(Rectangle())
    }

}

struct MenuPage: View {

    @EnvironmentObject var pagerState: PagerState

    var body: some View {
        ZStack {
            Color.clear
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
            .font(.title)
        }
        .contentShape(Rectangle())
    }

}

class PagerState: ObservableObject {

    @Published var activeIndex: Int = 1
    @Published var translation: CGFloat = .zero

}

struct MultiTransformationPagerView: View {

    @EnvironmentObject var pagerState: PagerState

    private let sidePage = SidePage()
    private let centerPage = CenterPage()
    private let menuPage = MenuPage()

    var body: some View {
        GeometryReader { geometry in
            self.pagerHorizontalStack(for: geometry.size.width)
                // Accounts for the initial offset position that shows the middle page first
                // Also accounts for subsequent page turns that change `currentIndex`
                .offset(x: -CGFloat(self.currentPageIndex) * geometry.size.width)
                // Accounts for user swipe gesture to go to a different page
                .offset(x: self.translation)
                .animation(.easeInOut)
                .gesture(
                    DragGesture().onChanged { value in
                        // `value` refers to the current data for the drag
                        self.pagerState.translation = value.translation.width
                    }.onEnded { value in
                        let pageTurnDelta = value.translation.width / geometry.size.width
                        // If the user has turned the page more than halfway, in which case
                        // `pageTurnDelta` > .5, we want to set the page that is being
                        // turned to as the new active page
                        let newIndex = Int((CGFloat(self.currentPageIndex) - pageTurnDelta).rounded())
                        // we don't want the index to be greater than 2 or less than 0
                        self.pagerState.activeIndex = min(max(newIndex, 0), 2)
                        self.pagerState.translation = .zero
                    }
                )
        }
    }

    private func pagerHorizontalStack(for pageWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            sidePage
                .frame(width: pageWidth)
            centerPage
                .frame(width: pageWidth)
                .clipShape(RoundedRectangle(
                    cornerRadius: centerCornerRadius(pageWidth: pageWidth),
                    style: .continuous))
                .frame(height: centerPageHeight(pageWidth: pageWidth))
            menuPage
                .frame(width: pageWidth)
                .rotation3DEffect(menuRotationAngle(pageWidth: pageWidth),
                                  axis: (x: 0, y: 10.0, z: 0),
                                  anchor: .leading)
                .opacity(menuOpacity(pageWidth: pageWidth))
        }
    }

}

fileprivate let deltaCutoff: CGFloat = 0.7

private extension MultiTransformationPagerView {

    var currentPageIndex: Int {
        pagerState.activeIndex
    }

    var translation: CGFloat {
        pagerState.translation
    }

    func pageTurnDelta(pageWidth: CGFloat) -> CGFloat {
        translation / pageWidth
    }

}

fileprivate let centerMinRadius: CGFloat = 0
fileprivate let centerCutoffRadius: CGFloat = 40
fileprivate let centerMaxRadius: CGFloat = centerMinRadius + centerCutoffRadius

private extension MultiTransformationPagerView {

    func centerCornerRadius(pageWidth: CGFloat) -> CGFloat {
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

            // negation for clearer syntax
            let radiusToBeAdded = -delta * (centerCutoffRadius / 0.7)
            return centerMinRadius + radiusToBeAdded
        } else if delta > 0 {
            // If we're swiping from the center page towards the first page, we don't
            // want any radius changes to the center page
            guard currentPageIndex == 2 else { return centerMinRadius }
            // Once the center page's radius gets restored to its initial radius, we don't
            // want to keep subtracting from its radius
            guard delta <= deltaCutoff else { return centerMinRadius }

            let radiusToBeSubtracted = delta * (centerCutoffRadius / 0.7)
            return centerMaxRadius - radiusToBeSubtracted
        } else {
            // When the user isn't dragging anything and the center page is active,
            // we don't want there to be any radius. But when the last page is active,
            // and there is no drag translation, we want the center page's radius to be at its max
            return currentPageIndex == 1 ? centerMinRadius : centerMaxRadius
        }
    }

}

fileprivate let centerMaxHeight = screen.height
fileprivate let centerCutoffHeight: CGFloat = 150
fileprivate let centerMinHeight: CGFloat = centerMaxHeight - centerCutoffHeight

private extension MultiTransformationPagerView {

    func centerPageHeight(pageWidth: CGFloat) -> CGFloat? {
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

            // negation for clearer syntax
            let heightToBeCutoff = -delta * (centerCutoffHeight / 0.7)
            return centerMaxHeight - heightToBeCutoff
        } else if delta > 0 {
            // If we're swiping from the center page towards the first page, we don't
            // want any height changes to the center page
            guard currentPageIndex == 2 else { return nil }
            // Once the center page's height gets restored to its initial height, we don't
            // want to keep adding to its height and make it greater than the screen's height
            guard delta <= deltaCutoff else { return nil }

            let heightToBeAdded = delta * (centerCutoffHeight / 0.7)
            return centerMinHeight + heightToBeAdded
        } else {
            // When the user isn't dragging anything, we want the center page to be fullscreen
            // when its active but at its min height when the last page is active
            return currentPageIndex == 1 ? nil : centerMinHeight
        }
    }

}

fileprivate let menuClosedDegrees: Double = 90
fileprivate let menuOpenDegrees: Double = 0

private extension MultiTransformationPagerView {

    func menuRotationAngle(pageWidth: CGFloat) -> Angle {
        // Center page's height should only be modified for the center and last page
        guard currentPageIndex != 0 else { return .init(degrees: menuClosedDegrees) }

        // We want to see how far we've swiped
        let delta = pageTurnDelta(pageWidth: pageWidth)

        // This means we're swiping left
        if delta < 0 {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, we don't want the menu's rotation angle to change
            guard currentPageIndex == 1 else { return .init(degrees: menuOpenDegrees) }
            // Now we know we're on the center page and we're swiping towards the last page,
            // we don't want to over rotate the menu page
            guard abs(delta) <= deltaCutoff else { return .init(degrees: menuOpenDegrees) }

            // negation for clearer syntax
            let degreesToBeSubtracted = Double(-delta) * (menuClosedDegrees / 0.7)
            return .init(degrees: menuClosedDegrees - degreesToBeSubtracted)
        } else if delta > 0 {
            // If we're swiping from the center page towards the first page, we don't
            // want any rotation changes to the menu page
            guard currentPageIndex == 2 else { return .init(degrees: menuClosedDegrees) }

            // When we're closing the menu, we don't account for the `deltaCutoff` because
            // we want the menu to close on the side of the screen, not partway across the screen
            let degreesToBeAdded = Double(delta) * menuClosedDegrees
            return .init(degrees: menuOpenDegrees + degreesToBeAdded)
        } else {
            // When the user isn't dragging anything and the center page is active, we want
            // the menu page to be closed. But when the menu page is active and there is no
            // drag, we want it to be open
            return currentPageIndex == 1 ? .init(degrees: menuClosedDegrees) : .init(degrees: menuOpenDegrees)
        }
    }

}

fileprivate let menuClosedOpacity: Double = 0
fileprivate let menuOpenOpacity: Double = 1

private extension MultiTransformationPagerView {

    func menuOpacity(pageWidth: CGFloat) -> Double {
        // Menu page's opacity should only be modified when either the center or menu is active
        guard currentPageIndex != 0 else { return menuClosedOpacity }

        // We want to see how far we've swiped
        let delta = pageTurnDelta(pageWidth: pageWidth)

        // This means we're swiping left
        if delta < 0 {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, the menu opacity should remain as it is open
            guard currentPageIndex == 1 else { return menuOpenOpacity }
            // Now we know we're on the center page and we're swiping towards the last page,
            // we don't want to add too much to the menu's opacity
            guard abs(delta) <= deltaCutoff else { return menuOpenOpacity }

            // negation for clearer syntax
            let opacityToBeAdded = Double(-delta) * (menuOpenOpacity / 0.7)
            return menuClosedOpacity + opacityToBeAdded
        } else if delta > 0 {
            // If we're swiping from the center page towards the first page, we don't
            // want any opaicty changes to the menu page
            guard currentPageIndex == 2 else { return menuClosedOpacity }

            // When we're closing the menu, we don't account for the `deltaCutoff` because
            // we want the menu to be fully faded once it reaches the edge of the screen,
            // not when it's halfway across
            let opacityToBeRemoved = Double(delta) * menuOpenOpacity
            return menuOpenOpacity - opacityToBeRemoved
        } else {
            // When the user isn't dragging anything and the center page is active, we want
            // the menu page to be fully faded. But when the menu page is active and there is no
            // drag, we want it to be fully visible
            return currentPageIndex == 1 ? menuClosedOpacity : menuOpenOpacity
        }
    }
}

struct MultiTransformationPagerView_Previews: PreviewProvider {
    static var previews: some View {
        MultiTransformationPagerView()
            .environmentObject(PagerState())
            .edgesIgnoringSafeArea(.all)
            .colorScheme(.dark)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
