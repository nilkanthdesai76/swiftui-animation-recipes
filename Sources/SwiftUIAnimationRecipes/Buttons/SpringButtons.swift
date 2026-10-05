import SwiftUI

// MARK: - Spring Press Button Style

/// A button style that provides a physics-based spring scale down on press and spring back on release.
///
/// Usage:
/// ```swift
/// Button("Tap Me") { }
///     .buttonStyle(.springPress(scale: 0.94, response: 0.25, dampingFraction: 0.6))
/// ```
public struct SpringPressButtonStyle: ButtonStyle {
    public var scale: CGFloat
    public var response: Double
    public var dampingFraction: Double

    public init(
        scale: CGFloat = 0.94,
        response: Double = 0.28,
        dampingFraction: Double = 0.6
    ) {
        self.scale = scale
        self.response = response
        self.dampingFraction = dampingFraction
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(
                .spring(response: response, dampingFraction: dampingFraction),
                value: configuration.isPressed
            )
    }
}

public extension ButtonStyle where Self == SpringPressButtonStyle {
    static var springPress: SpringPressButtonStyle {
        SpringPressButtonStyle()
    }

    static func springPress(
        scale: CGFloat = 0.94,
        response: Double = 0.28,
        dampingFraction: Double = 0.6
    ) -> SpringPressButtonStyle {
        SpringPressButtonStyle(
            scale: scale,
            response: response,
            dampingFraction: dampingFraction
        )
    }
}

// MARK: - Morphing Loading Button

/// A stateful button that morphs from an expanded label pill into a compact circular loading spinner.
///
/// Usage:
/// ```swift
/// MorphingButton(state: $buttonState, title: "Submit Order") {
///     // async action
/// }
/// ```
public enum MorphingButtonState: Equatable, Sendable {
    case idle
    case loading
    case success
    case failure
}

public struct MorphingButton: View {
    @Binding public var state: MorphingButtonState
    public var title: String
    public var idleColor: Color
    public var successColor: Color
    public var failureColor: Color
    public var action: () -> Void

    public init(
        state: Binding<MorphingButtonState>,
        title: String,
        idleColor: Color = .blue,
        successColor: Color = .green,
        failureColor: Color = .red,
        action: @escaping () -> Void
    ) {
        self._state = state
        self.title = title
        self.idleColor = idleColor
        self.successColor = successColor
        self.failureColor = failureColor
        self.action = action
    }

    private var currentColor: Color {
        switch state {
        case .idle, .loading: return idleColor
        case .success: return successColor
        case .failure: return failureColor
        }
    }

    public var body: some View {
        Button(action: {
            guard state == .idle else { return }
            action()
        }) {
            ZStack {
                // Background morphing shape
                Capsule()
                    .fill(currentColor)
                    .frame(
                        width: state == .loading ? 50 : 200,
                        height: 50
                    )

                // Foreground content
                Group {
                    switch state {
                    case .idle:
                        Text(title)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                            .transition(.opacity.combined(with: .scale))

                    case .loading:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                            .transition(.opacity.combined(with: .scale))

                    case .success:
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.opacity.combined(with: .scale))

                    case .failure:
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.72), value: state)
        }
        .buttonStyle(.plain)
        .disabled(state == .loading)
    }
}
