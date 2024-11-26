//  Created by Axel Ancona Esselmann on 11/19/24.
//

import SwiftUI

public enum DateIteratorType {
    case `default`, historic

    var iterator: some ElementIdIterator<Date> {
        switch self {
        case .default:
            return DayElemenIterator()
        case .historic:
            return DayElemenIterator(max: .now)
        }
    }
}

import SwiftUI
extension PageView where ElementId == Date {
    public init(
        selected: Binding<ElementId>,
        _ iteratorType: DateIteratorType = .default,
        idPages: Bool = false,
        @ViewBuilder
        _ content: @escaping (ElementId) -> Content
    ) {
        self.init(
            selected: selected,
            iteratorType.iterator,
            idPages: idPages,
            content
        )
    }
}
