//  Created by Axel Ancona Esselmann on 11/20/24.
//

import Foundation

public enum Impacts: Int, Hashable {
    case start, end, threshold

    static var all: Set<Self> {
        [.start, .end, .threshold]
    }
}

public extension Set where Element == Impacts {
    static var all: Self {
        Impacts.all
    }
}
