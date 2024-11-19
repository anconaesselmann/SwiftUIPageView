//  Created by Axel Ancona Esselmann on 11/19/24.
//

import Foundation

public struct IntElementIdIterator: ElementIdIterator {
    public let count: Int?
    public init(count: Int?) {
        self.count = count
    }
    public func index(after id: Int) -> Int? {
        let next = id + 1
        if let count {
            guard next < count else {
                return nil
            }
            return next
        } else {
            return next
        }
    }

    public func index(before id: Int) -> Int? {
        let prev = id - 1
        guard prev >= 0 else {
            return nil
        }
        return prev
    }
}
