import SwiftUI

// MARK: - Fluid Bottom Sheet Detents

public enum SheetDetent: CGFloat, CaseIterable, Sendable {
    case collapsed = 80
    case half = 340
    case expanded = 680
}

/// A custom draggable bottom sheet supporting physics springs, drag velocity, and snapping detents.
///
/// Usage:
/// ```swift
/// FluidBottomSheet(currentDetent: $sheetDetent) {
///     SheetContentView()
/// }
/// ```
public struct FluidBottomSheet<Content: View>: View {
    @Binding public var currentDetent: SheetDetent
    public var detents: [SheetDetent]
    public var backgroundColor: Color
    public var handleColor: Color
    public var content: Content

    @State private var dragOffset: CGFloat = 0

    public init(
        currentDetent: Binding<SheetDetent>,
        detents: [SheetDetent] = [.collapsed, .half, .expanded],
        backgroundColor: Color = Color(white: 0.98),
        handleColor: Color = .gray.opacity(0.4),
        @ViewBuilder content: () -> Content
    ) {
        self._currentDetent = currentDetent
        self.detents = detents.sorted { $0.rawValue < $1.rawValue }
        self.backgroundColor = backgroundColor
        self.handleColor = handleColor
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geo in
            let sheetHeight = currentDetent.rawValue - dragOffset

            VStack(spacing: 0) {
                // Drag grabber handle
                Capsule()
                    .fill(handleColor)
                    .frame(width: 36, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 12)

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(width: geo.size.width, height: max(sheetHeight, 60))
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: -4)
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        snapToClosestDetent(predictedEndTranslation: value.predictedEndTranslation.height)
                    }
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func snapToClosestDetent(predictedEndTranslation: CGFloat) {
        let currentHeight = currentDetent.rawValue - predictedEndTranslation
        let sortedDetents = detents.map(\.rawValue)

        // Find closest detent by distance
        let closestRaw = sortedDetents.min(by: { abs($0 - currentHeight) < abs($1 - currentHeight) }) ?? SheetDetent.half.rawValue
        let targetDetent = detents.first(where: { $0.rawValue == closestRaw }) ?? .half

        withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
            dragOffset = 0
            currentDetent = targetDetent
        }
    }
}

// Private cross-platform background helper
private extension Color {
    init(uiColorOrNSColorBackground: Void) {
        #if canImport(UIKit)
        self = Color(uiColor: .systemBackground)
        #elseif canImport(AppKit)
        self = Color(nsColor: .windowBackgroundColor)
        #else
        self = .white
        #endif
    }
}
