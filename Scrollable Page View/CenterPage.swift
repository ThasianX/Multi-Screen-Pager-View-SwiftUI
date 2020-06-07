// Kevin Li - 12:42 PM - 6/6/20

import SwiftUI

struct CenterPage: View, PagerStateDirectAccess {

    @EnvironmentObject var pagerState: PagerState

    var body: some View {
        ZStack {
            backdropColorWhenFaded
            content
                .opacity(contentOpacity)
        }
        .clipShape(RoundedRectangle(
            cornerRadius: centerCornerRadius,
            style: .continuous))
        .frame(width: pagerWidth, height: centerPageHeight)
    }

    private var backdropColorWhenFaded: Color {
        .blackPearl
    }

    private var content: some View {
        Group {
            AlternatingList()

            HStack {
                Spacer()
                MenuBarIndicator()
                    .padding(.trailing)
            }
        }
    }

}

fileprivate let centerMinOpacity: Double = 0
fileprivate let centerMaxOpacity: Double = 1

private extension CenterPage {

    var contentOpacity: Double {
        if isSwipingLeft {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, the center opacity should remain as it is
            guard currentPageIndex != 2 else { return centerMinOpacity }

            // swiping to menu page
            if currentPageIndex == 0 {
                // negation for clearer syntax
                let opacityToBeAdded = Double(-delta)
                return centerMinOpacity + opacityToBeAdded
            } else {
                // Now we know we're on the center page and we're swiping towards the menu page,
                // we don't want to subtract more opacity once fully faded
                guard abs(delta) <= deltaCutoff else { return centerMinOpacity }
                // negation for clearer syntax
                let opacityToBeRemoved = Double(-delta) * (centerMaxOpacity / Double(deltaCutoff))
                return centerMaxOpacity - opacityToBeRemoved
            }
        } else if isSwipingRight {
            // If we're at the side page and we're swiping right into the empty
            // space to the left, the center opacity should remain as it is
            guard currentPageIndex != 0 else { return centerMinOpacity }

            // swiping to side page
            if currentPageIndex == 1 {
                let opacityToBeRemoved = Double(delta)
                return centerMaxOpacity - opacityToBeRemoved
            } else {
                // Now we know we're on the menu page and we're swiping towards the center page,
                // we don't want to add more opacity once fully visible
                guard delta <= deltaCutoff else { return centerMaxOpacity }

                let opacityToBeAdded = Double(delta) * (centerMaxOpacity / Double(deltaCutoff))
                return centerMinOpacity + opacityToBeAdded
            }
        } else {
            // When the user isn't dragging anything and the center page is active, we want
            // the menu page to be fully faded. But when the menu page is active and there is no
            // drag, we want it to be fully visible
            return currentPageIndex == 1 ? centerMaxOpacity : centerMinOpacity
        }
    }

}

fileprivate let centerMaxHeight = screen.height
fileprivate let centerCutoffHeight: CGFloat = 80
fileprivate let centerMinHeight: CGFloat = centerMaxHeight - centerCutoffHeight

private extension CenterPage {

    var centerPageHeight: CGFloat {
        // Center page's height should only be modified for the center and last page
        guard currentPageIndex != 0 else { return centerMaxHeight }

        if isSwipingLeft {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, we don't want the center page's height to change.
            guard currentPageIndex == 1 else { return centerMinHeight }
            // Now we know we're on the center page and we're swiping towards the last page,
            // we don't want to cut off too much of the height
            guard abs(delta) <= deltaCutoff else { return centerMinHeight }

            // negation for clearer syntax
            let heightToBeCutoff = -delta * (centerCutoffHeight / deltaCutoff)
            return centerMaxHeight - heightToBeCutoff
        } else if isSwipingRight {
            // If we're swiping from the center page towards the first page, we don't
            // want any height changes to the center page
            guard currentPageIndex == 2 else { return centerMaxHeight }
            // Once the center page's height gets restored to its initial height, we don't
            // want to keep adding to its height and make it greater than the screen's height
            guard delta <= deltaCutoff else { return centerMaxHeight }

            let heightToBeAdded = delta * (centerCutoffHeight / deltaCutoff)
            return centerMinHeight + heightToBeAdded
        } else {
            // When the user isn't dragging anything, we want the center page to be fullscreen
            // when its active but at its min height when the last page is active
            return currentPageIndex == 1 ? centerMaxHeight : centerMinHeight
        }
    }

}

fileprivate let centerMinRadius: CGFloat = 0
fileprivate let centerCutoffRadius: CGFloat = 40
fileprivate let centerMaxRadius: CGFloat = centerMinRadius + centerCutoffRadius

private extension CenterPage {

    var centerCornerRadius: CGFloat {
        // Corner radius should only start being modified for the center and last page
        guard currentPageIndex != 0 else { return centerMinRadius }

        if isSwipingLeft {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, we don't want the center page's radius to change.
            guard currentPageIndex == 1 else { return centerMaxRadius }
            // Now we know we're on the center page and we're swiping towards the last page,
            // we don't want to add too much to the center radius
            guard abs(delta) <= deltaCutoff else { return centerMaxRadius }

            // negation for clearer syntax
            let radiusToBeAdded = -delta * (centerCutoffRadius / deltaCutoff)
            return centerMinRadius + radiusToBeAdded
        } else if isSwipingRight {
            // If we're swiping from the center page towards the first page, we don't
            // want any radius changes to the center page
            guard currentPageIndex == 2 else { return centerMinRadius }
            // Once the center page's radius gets restored to its initial radius, we don't
            // want to keep subtracting from its radius
            guard delta <= deltaCutoff else { return centerMinRadius }

            let radiusToBeSubtracted = delta * (centerCutoffRadius / deltaCutoff)
            return centerMaxRadius - radiusToBeSubtracted
        } else {
            // When the user isn't dragging anything and the center page is active,
            // we don't want there to be any radius. But when the last page is active,
            // and there is no drag translation, we want the center page's radius to be at its max
            return currentPageIndex == 1 ? centerMinRadius : centerMaxRadius
        }
    }

}

struct AlternatingList: View {

    private let items = ["PagePagePagePage", "PagePagePagePage", "PagePagePagePage", "PagePagePagePage", "PagePagePagePage", "PagePagePagePage", "PagePagePagePage", "PagePagePagePage", "PagePagePagePage", "PagePagePagePage" , "PagePagePagePage"]

    var body: some View {
        List {
            // Has to be in foreach for list row insets to work
            ForEach(0..<items.count) { i in
                ListRow(item: self.items[i],
                    isFilled: (i % 2) == 0)
                    .frame(height: 150)
            }
            .listRowInsets(EdgeInsets())
        }
    }

}

struct ListRow: View {

    let item: String
    let isFilled: Bool

    var body: some View {
        ZStack {
            backgroundColor
            Text(item)
                .font(.title)
        }
    }

    private var backgroundColor: Color {
        isFilled ? .blackPearl : .blackPearlComplement
    }

}

struct MenuBarIndicator: View {

    var body: some View {
        VStack {
            Circle()
                .frame(width: 8, height: 8)
            Circle()
                .frame(width: 8, height: 8)
            Circle()
                .frame(width: 8, height: 8)
        }
        .foregroundColor(.white)
    }

}
