//  Created by Axel Ancona Esselmann on 11/19/24.
//

import SwiftUI

public struct PageView<Content, ElementId>: View
    where
        Content: View,
        ElementId: Hashable

{
    @Binding
    private var selected: ElementId

    private let elementIterator: any ElementIdIterator<ElementId>

    @State
    private var direction: Direction = .rightToLeft

    @State
    private var rect: CGSize = .zero

    @State
    private var frame: CGSize = .zero
    @State
    private var width: CGFloat = .zero

    private var pageBackgroundColor: Color = .clear

    public func pageBackground(color: Color) -> Self {
        var copy = self
        copy.pageBackgroundColor = color
        return copy
    }

    private enum Direction {
        case rightToLeft, leftToRight
    }

    @State
    private var isDragging = false

    private let content: (ElementId) -> Content

    var _adjustOnSwipe: Bool

    public init(
        selected: Binding<ElementId>,
        _ elementIterator: any ElementIdIterator<ElementId>,
        adjustOnSwipe: Bool = false,
        @ViewBuilder
        _ content: @escaping (ElementId) -> Content
    ) {
        _selected = selected
        self.elementIterator = elementIterator
        self._adjustOnSwipe = adjustOnSwipe
        self.content = content
    }

    @ViewBuilder
    private func _pageBackground() -> some View {
        if _adjustOnSwipe {
            GeometryReader {
                pageBackgroundColor.preference(
                    key: ViewRectKey.self,
                    value: [$0.frame(in: .local)]
                )
            }
        } else {
            pageBackgroundColor
        }
    }

    public var body: some View {
        ZStack {
//        ZStack(alignment: .top) {
            if
                isDragging,
                direction == .leftToRight,
                let previous = elementIterator.index(before: selected)
            {
                content(previous)
                    .frame(width: width)
                    .background(_pageBackground())
                    .offset(CGSize(width: rect.width - width, height: 0))
            }
            if
                isDragging,
                direction == .rightToLeft,
                let next = elementIterator.index(after: selected)
            {
                content(next)
                    .frame(width: width)
                    .background(_pageBackground())
                    .offset(CGSize(width: rect.width + width, height: 0))
            }
            content(selected)
                .background(GeometryReader {
                    pageBackgroundColor.preference(
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
                    DragGesture(minimumDistance: 2)
                        .onChanged { gesture in
                            if !isDragging, abs(gesture.translation.height) > 5 {
                                rect = .zero
                                return
                            }
                            if isDragging != true {
                                isDragging = true
                            }
                            let newDirection: Direction = gesture.translation.width < 0
                                    ? .rightToLeft
                                    : .leftToRight
                            if newDirection != direction {
                                direction = newDirection
                            }
                            withAnimation {
                                rect = CGSize(width: gesture.translation.width, height: 0)
                            }
                        }
                        .onEnded { gesture in
                            withAnimation {
                                if abs(gesture.translation.width) > 100 {
                                    switch direction {
                                    case .rightToLeft:
                                        if let next = elementIterator.index(after: selected) {
                                            rect = CGSize(width: -width, height: 0)
                                        } else {
                                            rect = .zero
                                        }
                                    case .leftToRight:
                                        if let previous = elementIterator.index(before: selected) {
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
                                        if let next = elementIterator.index(after: selected) {
                                            selected = next
                                        }
                                    case .leftToRight:
                                        if let before = elementIterator.index(before: selected) {
                                            selected = before
                                        }
                                    }
                                }
                                isDragging = false
                            }
                        }
                )
                .frame(width: width)
        }
        .frame(height: frame.height)
        .frame(maxWidth: .infinity)
        .background(GeometryReader { proxy in
            pageBackgroundColor
                .onAppear {
                    // TODO: Read change from environment to adjust width when device rotates or window gets rescaled
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

public extension PageView {
    func adjustOnSwipe() -> Self {
        var copy = self
        copy._adjustOnSwipe = true
        return copy
    }
}
