//  Created by Axel Ancona Esselmann on 11/19/24.
//

import SwiftUI

// Credit goes to https://stackoverflow.com/users/12299030/asperi for observing the height
// of a view using Preference Keys
public struct ViewRectKey: PreferenceKey {
    public typealias Value = Array<CGRect>
    public static var defaultValue = [CGRect]()
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
