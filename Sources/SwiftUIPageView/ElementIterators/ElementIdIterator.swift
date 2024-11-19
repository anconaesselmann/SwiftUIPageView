//  Created by Axel Ancona Esselmann on 11/19/24.
//

import Foundation

public protocol ElementIdIterator<ElementId> {
    associatedtype ElementId
        where ElementId: Hashable

    func index(after id: ElementId) -> ElementId?

    func index(before id: ElementId) -> ElementId?
}
