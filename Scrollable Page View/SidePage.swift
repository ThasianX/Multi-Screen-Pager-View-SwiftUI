// Kevin Li - 12:42 PM - 6/6/20

import SwiftUI

struct SidePage: View, PagerStateDirectAccess {

    @EnvironmentObject var pagerState: PagerState

    var body: some View {
        ZStack(alignment: .leading) {
            Color.green
            VStack(spacing: 0) {
                Text("PagePagePagePagePagePagePagePage")
                Text("PagePagePagePagePagePagePagePage")
                Text("PagePagePagePagePagePagePagePage")
                Text("PagePagePagePagePagePagePagePage")
                Text("PagePagePagePagePagePagePagePage")
            }
            .font(.title)
        }
        .contentShape(Rectangle())
        .frame(width: pagerWidth)
    }

}
