// Kevin Li - 12:42 PM - 6/6/20

import SwiftUI

struct MenuPage: View, PagerStateDirectAccess {

    @EnvironmentObject var pagerState: PagerState

    var body: some View {
        ZStack {
            Color.clear
            VStack(alignment: .leading, spacing: 0) {
                Text("Menu")
                    .font(.largeTitle)
                Text("PagePagePagePagePagePagePagePage")
                Text("PagePagePagePagePagePagePagePage")
                Text("PagePagePagePagePagePagePagePage")
                Text("PagePagePagePagePagePagePagePage")
                Text("PagePagePagePagePagePagePagePage")
            }
            .font(.title)
            .padding(.horizontal)
        }
        .contentShape(Rectangle())
        .rotation3DEffect(menuRotationAngle,
                          axis: (x: 0, y: 10.0, z: 0),
                          anchor: .leading)
        .opacity(menuOpacity)
        .frame(width: pagerWidth * deltaCutoff)
    }

}

fileprivate let menuClosedDegrees: Double = 90
fileprivate let menuOpenDegrees: Double = 0

private extension MenuPage {

    var menuRotationAngle: Angle {
        // Center page's height should only be modified for the center and last page
        guard currentPageIndex != 0 else { return .init(degrees: menuClosedDegrees) }

        if isSwipingLeft {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, we don't want the menu's rotation angle to change
            guard currentPageIndex == 1 else { return .init(degrees: menuOpenDegrees) }
            // Now we know we're on the center page and we're swiping towards the last page,
            // we don't want to over rotate the menu page
            guard abs(delta) <= deltaCutoff else { return .init(degrees: menuOpenDegrees) }

            // negation for clearer syntax
            let degreesToBeSubtracted = Double(-delta) * (menuClosedDegrees / Double(deltaCutoff))
            return .init(degrees: menuClosedDegrees - degreesToBeSubtracted)
        } else if isSwipingRight {
            // If we're swiping from the center page towards the first page, we don't
            // want any rotation changes to the menu page
            guard currentPageIndex == 2 else { return .init(degrees: menuClosedDegrees) }
            // Once the menu page is folded again, we don't want to keep folding even more
            guard delta <= deltaCutoff else { return .init(degrees: menuClosedDegrees) }

            let degreesToBeAdded = Double(delta) * (menuClosedDegrees / Double(deltaCutoff))
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

private extension MenuPage {

    var menuOpacity: Double {
        // Menu page's opacity should only be modified when either the center or menu is active
        guard currentPageIndex != 0 else { return menuClosedOpacity }

        if isSwipingLeft {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, the menu opacity should remain as it is open
            guard currentPageIndex == 1 else { return menuOpenOpacity }
            // Now we know we're on the center page and we're swiping towards the last page,
            // we don't want to add too much to the menu's opacity
            guard abs(delta) <= deltaCutoff else { return menuOpenOpacity }

            // negation for clearer syntax
            let opacityToBeAdded = Double(-delta) * (menuOpenOpacity / Double(deltaCutoff))
            return menuClosedOpacity + opacityToBeAdded
        } else if isSwipingRight {
            // If we're swiping from the center page towards the first page, we don't
            // want any opaicty changes to the menu page
            guard currentPageIndex == 2 else { return menuClosedOpacity }
            // Once the menu page is faded entirely, we don't want to keep fading
            guard delta <= deltaCutoff else { return menuClosedOpacity }

            let opacityToBeRemoved = Double(delta) * (menuOpenOpacity / Double(deltaCutoff))
            return menuOpenOpacity - opacityToBeRemoved
        } else {
            // When the user isn't dragging anything and the center page is active, we want
            // the menu page to be fully faded. But when the menu page is active and there is no
            // drag, we want it to be fully visible
            return currentPageIndex == 1 ? menuClosedOpacity : menuOpenOpacity
        }
    }
}
