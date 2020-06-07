// Kevin Li - 10:44 AM - 5/31/20

import Foundation
import SwiftUI

let screen = UIScreen.main.bounds

struct MultiTransformationPagerView: View {

    var body: some View {
        GeometryReader { geometry in
            _MultiTransformationPagerView()
                // The alignment property here is crucial because we are telling the geometry
                // reader to layout the HStack starting from left. As a result, the middle page
                // is initially shown. If you try any other alignment, you'll notice that the initial
                // setup of the HStack is wrong.
                // The alignment property also influences the scroll direction. By laying out our
                // pages left to right, we are specifying that to get to the next page, the user has
                // to scroll in the leftward direction.
                .frame(width: geometry.size.width, alignment: .leading)
                .environmentObject(PagerState(pagerWidth: geometry.size.width,
                                              deltaCutoff: 0.8))
        }
    }

}

struct _MultiTransformationPagerView: View, PagerStateDirectAccess {

    @EnvironmentObject var pagerState: PagerState

    private var pageOffset: CGFloat {
        var offset = -CGFloat(currentPageIndex) * pagerWidth
        if currentPageIndex == 2 {
            // Because the menu has a fraction of the screen's width,
            // we have to account for that in the offset
            offset += pagerWidth * (1 - deltaCutoff)
        }
        return offset
    }

    private var boundedTranslation: CGFloat {
        if (currentPageIndex == 0 && translation > 0) ||
            (currentPageIndex == 2 && translation < 0) {
            return 0
        }
        return translation
    }

    private let sidePage = SidePage()
    private let centerPage = CenterPage()
    private let menuPage = MenuPage()

    var body: some View {
        pagerHorizontalStack
            // Accounts for the initial offset position that shows the middle page first
            // Also accounts for subsequent page turns that change `currentIndex`
            .offset(x: pageOffset)
            // Accounts for user swipe gesture to go to a different page
            .offset(x: boundedTranslation)
            .animation(.easeInOut)
            .gesture(
                DragGesture().onChanged { value in
                    // `value` refers to the current data for the drag
                    self.pagerState.translation = value.translation.width
                }.onEnded { value in
                    let pageTurnDelta = value.translation.width / self.pagerWidth
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

    private var pagerHorizontalStack: some View {
        HStack(alignment: .center, spacing: 0) {
            sidePage
            centerPage
            menuPage
        }
    }
    
}

struct MultiTransformationPagerView_Previews: PreviewProvider {
    static var previews: some View {
        MultiTransformationPagerView()
            .edgesIgnoringSafeArea(.all)
            .colorScheme(.dark)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
