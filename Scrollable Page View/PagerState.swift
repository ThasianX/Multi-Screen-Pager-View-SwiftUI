// Kevin Li - 5:20 PM - 6/6/20

import SwiftUI

class PagerState: ObservableObject {

    @Published var activeIndex: Int = 1
    @Published var translation: CGFloat = .zero

    let pagerWidth: CGFloat
    let deltaCutoff: CGFloat

    init(pagerWidth: CGFloat, deltaCutoff: CGFloat) {
        self.pagerWidth = pagerWidth
        self.deltaCutoff = deltaCutoff
    }

}

protocol PagerStateDirectAccess {

    var pagerState: PagerState { get }

}

extension PagerStateDirectAccess {

    var pagerWidth: CGFloat {
        pagerState.pagerWidth
    }

    var deltaCutoff: CGFloat {
        pagerState.deltaCutoff
    }

    var currentPageIndex: Int {
        pagerState.activeIndex
    }

    var translation: CGFloat {
        pagerState.translation
    }

    var delta: CGFloat {
        translation / pagerWidth
    }

    var isSwipingLeft: Bool {
        translation < 0
    }

    var isSwipingRight: Bool {
        translation > 0
    }

}
