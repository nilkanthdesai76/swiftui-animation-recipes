import SwiftUI

// MARK: - Shimmer Skeleton Modifier

/// A shimmer sweep modifier that creates a dynamic loading skeleton across any SwiftUI shape or layout.
///
/// Usage:
/// ```swift
/// RoundedRectangle(cornerRadius: 8)
///     .frame(height: 20)
///     .shimmering()
/// ```
public struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    public var active: Bool
    public var duration: Double
    public var bounce: Bool
    public var bandColor: Color
    public var baseColor: Color

    public init(
        active: Bool = true,
        duration: Double = 1.5,
        bounce: Bool = false,
        bandColor: Color = Color.white.opacity(0.45),
        baseColor: Color = Color.gray.opacity(0.2)
    ) {
        self.active = active
        self.duration = duration
        self.bounce = bounce
        self.bandColor = bandColor
        self.baseColor = baseColor
    }

    public func body(content: Content) -> some View {
        if !active {
            content
        } else {
            content
                .overlay(
                    GeometryReader { geo in
                        let size = geo.size
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: bandColor, location: 0.45),
                                .init(color: bandColor, location: 0.55),
                                .init(color: .clear, location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: size.width * 2, height: size.height * 2)
                        .offset(x: -size.width + (phase * size.width * 2))
                    }
                    .mask(content)
                )
                .onAppear {
                    withAnimation(
                        .linear(duration: duration)
                        .repeatForever(autoreverses: bounce)
                    ) {
                        phase = 1.0
                    }
                }
        }
    }
}

public extension View {
    /// Applies an animated shimmer gradient mask across the view.
    func shimmering(
        active: Bool = true,
        duration: Double = 1.4,
        bounce: Bool = false,
        bandColor: Color = Color.white.opacity(0.4)
    ) -> some View {
        modifier(ShimmerModifier(
            active: active,
            duration: duration,
            bounce: bounce,
            bandColor: bandColor
        ))
    }
}

// MARK: - Skeleton Placeholder Views

/// Pre-built skeleton row placeholder for lists, feeds, and profiles.
public struct SkeletonListRow: View {
    public var showAvatar: Bool

    public init(showAvatar: Bool = true) {
        self.showAvatar = showAvatar
    }

    public var body: some View {
        HStack(spacing: 14) {
            if showAvatar {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 48, height: 48)
            }

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 14)
                    .frame(maxWidth: .infinity)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 11)
                    .frame(maxWidth: 180)
            }
        }
        .padding(.vertical, 8)
        .shimmering()
    }
}

/// Pre-built skeleton card placeholder.
public struct SkeletonCard: View {
    public var height: CGFloat

    public init(height: CGFloat = 200) {
        self.height = height
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(height: height - 60)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 14)
                .frame(maxWidth: .infinity)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 11)
                .frame(maxWidth: 120)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.08))
        )
        .shimmering()
    }
}
