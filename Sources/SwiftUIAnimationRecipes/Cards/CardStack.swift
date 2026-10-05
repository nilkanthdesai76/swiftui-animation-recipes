import SwiftUI

// MARK: - Swipeable Card Stack

/// Direction of a completed card swipe gesture.
public enum SwipeDirection: Sendable {
    case left
    case right
}

/// A Tinder/Bumble-style interactive card stack with spring-driven drag gestures and tilt rotation.
///
/// Usage:
/// ```swift
/// CardStack(items: profiles) { profile in
///     ProfileCardView(profile)
/// } onSwipe: { profile, direction in
///     print("Swiped \(direction) on \(profile)")
/// }
/// ```
public struct CardStack<Item: Identifiable, CardContent: View>: View {
    public var items: [Item]
    public var maxVisibleCards: Int
    public var cardContent: (Item) -> CardContent
    public var onSwipe: (Item, SwipeDirection) -> Void

    @State private var offset: CGSize = .zero
    @State private var rotation: Angle = .zero

    public init(
        items: [Item],
        maxVisibleCards: Int = 3,
        @ViewBuilder cardContent: @escaping (Item) -> CardContent,
        onSwipe: @escaping (Item, SwipeDirection) -> Void
    ) {
        self.items = items
        self.maxVisibleCards = maxVisibleCards
        self.cardContent = cardContent
        self.onSwipe = onSwipe
    }

    public var body: some View {
        ZStack {
            ForEach(Array(visibleItems.enumerated()), id: \.element.id) { index, item in
                let isTopCard = index == visibleItems.count - 1
                let reverseIndex = visibleItems.count - 1 - index

                cardContent(item)
                    .scaleEffect(scale(for: reverseIndex))
                    .offset(y: yOffset(for: reverseIndex))
                    .offset(isTopCard ? offset : .zero)
                    .rotationEffect(isTopCard ? rotation : .zero)
                    .zIndex(Double(index))
                    .gesture(
                        isTopCard ? dragGesture(for: item) : nil
                    )
            }
        }
    }

    private var visibleItems: [Item] {
        Array(items.prefix(maxVisibleCards).reversed())
    }

    private func scale(for index: Int) -> CGFloat {
        1.0 - (CGFloat(index) * 0.05)
    }

    private func yOffset(for index: Int) -> CGFloat {
        CGFloat(index) * 12
    }

    private func dragGesture(for item: Item) -> some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
                let degrees = Double(value.translation.width / 20)
                rotation = .degrees(degrees)
            }
            .onEnded { value in
                let threshold: CGFloat = 130
                if value.translation.width > threshold {
                    // Swiped Right
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                        offset = CGSize(width: 500, height: value.translation.height)
                        rotation = .degrees(25)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        onSwipe(item, .right)
                        resetOffset()
                    }
                } else if value.translation.width < -threshold {
                    // Swiped Left
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                        offset = CGSize(width: -500, height: value.translation.height)
                        rotation = .degrees(-25)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        onSwipe(item, .left)
                        resetOffset()
                    }
                } else {
                    // Snap back
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                        resetOffset()
                    }
                }
            }
    }

    private func resetOffset() {
        offset = .zero
        rotation = .zero
    }
}
