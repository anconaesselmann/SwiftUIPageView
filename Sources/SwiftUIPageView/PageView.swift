//  Created by Axel Ancona Esselmann on 11/19/24.
//

import SwiftUI

public struct PageView<Content: View>: View {
    @Binding
    private var selected: Int

    private let count: Int = 7

    @State
    private var direction: Direction = .rightToLeft

    @State
    private var rect: CGSize = .zero

    @State
    private var frame: CGSize = .zero
    @State
    private var width: CGFloat = .zero

    private enum Direction {
        case rightToLeft, leftToRight
    }

    @State
    private var isDragging = false

    private let content: (Int) -> Content

    public init(
        selected: Binding<Int>,
        @ViewBuilder
        _ content: @escaping (Int) -> Content
    ) {
        _selected = selected
        self.content = content
    }

    public var body: some View {
        ZStack {
//        ZStack(alignment: .top) {
            if isDragging, direction == .leftToRight, selected - 1 >= 0 {
                content(selected - 1)
                    .offset(CGSize(width: rect.width - width, height: 0))
                    .frame(width: width)
            }
            content(selected)
                .background(GeometryReader {
                    Color.clear.preference(
                        key: ViewRectKey.self,
                        value: [$0.frame(in: .local)]
                    )
                })
                .offset(rect)
                .transition(
                    direction == .rightToLeft
                    ? .asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    )
                    : .asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .trailing)
                    )
                )
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if isDragging != true {
                                isDragging = true
                            }
                            let newDirection: Direction = gesture.translation.width < 0
                                    ? .rightToLeft
                                    : .leftToRight
                            if newDirection != direction {
                                direction = newDirection
                            }
                            rect = CGSize(width: gesture.translation.width, height: 0)
                            print(rect, direction, isDragging, selected)
                        }
                        .onEnded { gesture in
                            withAnimation {
                                if abs(gesture.translation.width) > 100 {
                                    switch direction {
                                    case .rightToLeft:
                                        if selected + 1 < count {
                                            rect = CGSize(width: -width, height: 0)
                                        } else {
                                            rect = .zero
                                        }
                                    case .leftToRight:
                                        if selected - 1 >= 0 {
                                            rect = CGSize(width: width, height: 0)
                                        } else {
                                            rect = .zero
                                        }
                                    }
                                } else {
                                    rect = .zero
                                }
                            } completion: {
                                if abs(gesture.translation.width) > 100 {
                                    rect = .zero
                                    switch direction {
                                    case .rightToLeft:
                                        if selected + 1 < count {
                                            selected = min(selected + 1, count - 1)
                                        }
                                    case .leftToRight:
                                        if selected - 1 >= 0 {
                                            selected = max(selected - 1, 0)
                                        }
                                    }
                                }
                                isDragging = false
                            }
                        }
                )
                .frame(width: width)
            if isDragging, direction == .rightToLeft, selected + 1 < count {
                content(selected + 1)
                    .offset(CGSize(width: rect.width + width, height: 0))
                    .frame(width: width)
            }
        }
        .frame(height: frame.height)
        .frame(maxWidth: .infinity)
        .background(GeometryReader { proxy in
            Color.clear
                .onAppear {
                    width = proxy.size.width
                }
        })
        .onPreferenceChange(ViewRectKey.self) { rects in
            let new = rects.first ?? .zero
            Task { @MainActor in
                withAnimation {
                    frame = new.size
                }
            }
        }
        .clipped()
    }
}


extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

public struct ViewRectKey: PreferenceKey {
    public typealias Value = Array<CGRect>
    public static var defaultValue = [CGRect]()
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
