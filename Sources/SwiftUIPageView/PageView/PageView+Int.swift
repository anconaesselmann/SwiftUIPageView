//  Created by Axel Ancona Esselmann on 11/19/24.
//

import SwiftUI

public extension PageView where ElementId == Int {
    public init(
        selected: Binding<ElementId>,
        @ViewBuilder
        _ content: @escaping (ElementId) -> Content
    ) {
        self.init(
            selected: selected,
            IntElementIdIterator(count: nil),
            content
        )
    }
}
