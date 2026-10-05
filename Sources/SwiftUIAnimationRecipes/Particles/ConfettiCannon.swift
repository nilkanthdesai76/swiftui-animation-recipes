import SwiftUI

// MARK: - Confetti Particle Model

public struct ConfettiParticle: Identifiable, Sendable {
    public let id: UUID
    public var x: CGFloat
    public var y: CGFloat
    public var color: Color
    public var size: CGFloat
    public var rotation: Double
    public var rotationSpeed: Double
    public var opacity: Double
    public var scale: CGFloat

    public init(
        id: UUID = UUID(),
        x: CGFloat = 0,
        y: CGFloat = 0,
        color: Color = .blue,
        size: CGFloat = 8,
        rotation: Double = 0,
        rotationSpeed: Double = 0,
        opacity: Double = 1.0,
        scale: CGFloat = 1.0
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.color = color
        self.size = size
        self.rotation = rotation
        self.rotationSpeed = rotationSpeed
        self.opacity = opacity
        self.scale = scale
    }
}

// MARK: - Confetti Cannon Modifier

/// An explosive confetti cannon trigger modifier for celebration, achievements, and purchase events.
///
/// Usage:
/// ```swift
/// Button("Celebrate!") { triggerConfetti.toggle() }
///     .confettiCannon(trigger: $triggerConfetti, count: 60)
/// ```
public struct ConfettiCannonModifier: ViewModifier {
    @Binding public var trigger: Bool
    public var count: Int
    public var colors: [Color]
    public var duration: Double

    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating: Bool = false

    public init(
        trigger: Binding<Bool>,
        count: Int = 50,
        colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink],
        duration: Double = 2.0
    ) {
        self._trigger = trigger
        self.count = count
        self.colors = colors
        self.duration = duration
    }

    public func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    ForEach(particles) { particle in
                        RoundedRectangle(cornerRadius: particle.size * 0.2)
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size * 1.6)
                            .scaleEffect(particle.scale)
                            .rotationEffect(.degrees(particle.rotation))
                            .offset(x: particle.x, y: particle.y)
                            .opacity(particle.opacity)
                    }
                }
                .allowsHitTesting(false)
            )
            .onChange(of: trigger) { newValue in
                if newValue {
                    fireCannon()
                }
            }
    }

    private func fireCannon() {
        guard !isAnimating else { return }
        isAnimating = true

        // Generate initial explosion particles
        particles = (0..<count).map { _ in
            ConfettiParticle(
                x: 0,
                y: 0,
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 6...12),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: 180...720),
                opacity: 1.0,
                scale: 0.1
            )
        }

        // Animate explosion outward
        withAnimation(.easeOut(duration: duration * 0.4)) {
            particles = particles.map { p in
                var updated = p
                let angle = Double.random(in: -Double.pi * 0.9...(-Double.pi * 0.1))
                let distance = CGFloat.random(in: 100...250)
                updated.x = cos(angle) * distance
                updated.y = sin(angle) * distance
                updated.scale = 1.0
                updated.rotation += p.rotationSpeed * 0.5
                return updated
            }
        }

        // Animate gravity drift downward & fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + (duration * 0.35)) {
            withAnimation(.easeIn(duration: self.duration * 0.65)) {
                self.particles = self.particles.map { p in
                    var updated = p
                    updated.y += CGFloat.random(in: 120...300)
                    updated.x += CGFloat.random(in: -40...40)
                    updated.opacity = 0.0
                    updated.scale = 0.6
                    updated.rotation += p.rotationSpeed
                    return updated
                }
            }
        }

        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.particles = []
            self.isAnimating = false
            self.trigger = false
        }
    }
}

public extension View {
    func confettiCannon(
        trigger: Binding<Bool>,
        count: Int = 50,
        colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink],
        duration: Double = 2.0
    ) -> some View {
        modifier(ConfettiCannonModifier(
            trigger: trigger,
            count: count,
            colors: colors,
            duration: duration
        ))
    }
}
