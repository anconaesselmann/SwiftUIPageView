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

    private let _lightImpact = UIImpactFeedbackGenerator(style: .light)

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

    var isDraggingBinding: Binding<Bool>?

    @State
    private var impactedWhenThresholdExceeded: Bool = false

    @State
    private var thresholdCrossed: Bool = false

    private let content: (ElementId) -> Content

    internal var _adjustOnSwipe: Bool

    internal var _impacts: Set<Impacts> = []

    internal var _threshold: Double = 0.25

    internal var _onThresholdCrossed: ((ElementId?) -> Void)?

    public init(
        selected: Binding<ElementId>,
        _ elementIterator: any ElementIdIterator<ElementId>,
        adjustOnSwipe: Bool = false,
        idPages: Bool = false,
        @ViewBuilder
        _ content: @escaping (ElementId) -> Content
    ) {
        _selected = selected
        self.elementIterator = elementIterator
        self._adjustOnSwipe = adjustOnSwipe
        self.content = content
        let id = UUID()
        self.id = id
        self.next = id
        self.idPages = idPages
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

    let idPages: Bool
    @State
    var id: UUID
    @State
    var next: UUID

    public var body: some View {
        ZStack {
            if
                isDragging,
                direction == .leftToRight,
                let previous = elementIterator.index(before: selected)
            {
                content(previous)
                    .frame(width: width)
                    .background(_pageBackground())
                    .if(idPages) {
                        $0.id(next)
                    }
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
                    .if(idPages) {
                        $0.id(next)
                    }
                    .offset(CGSize(width: rect.width + width, height: 0))
            }
            content(selected)
                .background(GeometryReader {
                    pageBackgroundColor.preference(
                        key: ViewRectKey.self,
                        value: [$0.frame(in: .local)]
                    )
                })
                .if(idPages) {
                    $0.id(id)
                }
                .offset(rect)
                .transition(.identity)
                .gesture(
                    DragGesture(minimumDistance: 2)
                        .onChanged { gesture in
                            if !isDragging, abs(gesture.translation.height) > 5 {
                                rect = .zero
                                return
                            }
                            if isDragging != true {
                                if idPages {
                                    next = UUID()
                                }
                                isDragging = true
                                isDraggingBinding?.wrappedValue = true
                                if _impacts.contains(.start) {
                                    _lightImpact.impactOccurred()
                                }
                            }
                            let newDirection: Direction = gesture.translation.width < 0
                                    ? .rightToLeft
                                    : .leftToRight
                            if newDirection != direction {
                                direction = newDirection
                            }
                            if _impacts.contains(.threshold) {
                                if abs(gesture.translation.width) > min((width * _threshold), 500) {
                                    if !impactedWhenThresholdExceeded {
                                        impactedWhenThresholdExceeded = true
                                        _lightImpact.impactOccurred()
                                    }
                                } else if impactedWhenThresholdExceeded {
                                    impactedWhenThresholdExceeded = false
                                    _lightImpact.impactOccurred()
                                }
                            }

                            if abs(gesture.translation.width) > min((width * _threshold), 500) {
                                if !thresholdCrossed {
                                    thresholdCrossed = true
                                    setNewHeight()
                                    if direction == .rightToLeft {
                                        if let next = elementIterator.index(after: selected) {
                                            _onThresholdCrossed?(next)
                                        }
                                    } else if direction == .leftToRight {
                                        if let prev = elementIterator.index(before: selected) {
                                            _onThresholdCrossed?(prev)
                                        }
                                    }
                                }
                            } else if thresholdCrossed {
                                thresholdCrossed = false
                                setOldHeight()
                                _onThresholdCrossed?(nil)
                            }
                            withAnimation {
                                rect = CGSize(width: gesture.translation.width, height: 0)
                            }
                        }
                        .onEnded { gesture in
                            guard isDragging else {
                                return
                            }
                            withAnimation {
                                if abs(gesture.translation.width) > min((width * _threshold), 500) {
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
                                if abs(gesture.translation.width) > min((width * _threshold), 300) {
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
                                    if !isDragging, _impacts.contains(.end) {
                                        _lightImpact.impactOccurred()
                                    }
                                }
                                if impactedWhenThresholdExceeded {
                                    impactedWhenThresholdExceeded = false
                                }
                                if isDragging, _impacts.contains(.end) {
                                    _lightImpact.impactOccurred()
                                }
                                isDragging = false
                                if idPages {
                                    id = next
                                }
                                isDraggingBinding?.wrappedValue = false
                                _onThresholdCrossed?(nil)
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
            self.rects = rects
            if rects.count == 1 {
                setNewHeight()
            }
        }
        .clipped()
    }

    @State
    var rects: ViewRectKey.Value?

    func setNewHeight() {
        let new = rects?.first ?? .zero
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 1_000_000)
            withAnimation {
                frame = new.size
            }
        }
    }

    func setOldHeight() {
        let old = rects?.last ?? .zero
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 1_000_000)
            withAnimation {
                frame = old.size
            }
        }
    }
}

public extension PageView {
    func adjustOnSwipe() -> Self {
        var copy = self
        copy._adjustOnSwipe = true
        return copy
    }

    func impacts(_ impacts: Set<Impacts>) -> Self {
        var copy = self
        copy._impacts = impacts
        return copy
    }

    func impacts(_ impacts: Impacts...) -> Self {
        self.impacts(Set(impacts))
    }

    func threshold(_ threshold: Double) -> Self {
        var copy = self
        copy._threshold = min(0.75, max(0.05, threshold))
        return copy
    }

    func onThresholdCrossed(_ onCrossed: @escaping (ElementId?) -> Void) -> Self {
        var copy = self
        copy._onThresholdCrossed = onCrossed
        return copy
    }

    func isDragging(_ isDragging: Binding<Bool>) -> Self {
        var copy = self
        copy.isDraggingBinding = isDragging
        return copy
    }
}

// https://www.avanderlee.com/swiftui/conditional-view-modifier/
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
