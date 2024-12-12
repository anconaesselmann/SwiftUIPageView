//  Created by Axel Ancona Esselmann on 11/25/24.
//

import SwiftUI
import SwiftUIPageView

// Note: Does not compensate for DTS changes
public struct WeekElementIterator: ElementIdIterator {

    private let max: Date?
    private let min: Date?

    public init(
        max: Date? = nil,
        min: Date? = nil
    ) {
        self.max = max
        self.min = min
    }

    public func index(after id: Date) -> Date? {
        let next = id.addingTimeInterval(86400 * 7)
        if let max {
            guard next <= max else {
                return nil
            }
            return next
        } else {
            return next
        }
    }

    public func index(before id: Date) -> Date? {
        let prev = id.addingTimeInterval(-86400 * 7)
        if let min {
            guard prev >= min else {
                return nil
            }
            return prev
        } else {
            return prev
        }
    }
}

