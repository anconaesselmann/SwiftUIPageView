//  Created by Axel Ancona Esselmann on 11/19/24.
//

import Foundation

public struct DayElemenIterator: ElementIdIterator {
    private let max: Date?
    private let min: Date?

    public init(max: Date? = nil, min: Date? = nil) {
        self.max = max
        self.min = min
    }

    public func index(after id: Date) -> Date? {
        let next = id.addingTimeInterval(86400)
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
        let prev = id.addingTimeInterval(-86400)
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
