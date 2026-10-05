import SwiftUI

// MARK: - Magnetic Floating Tab Bar

public struct TabItem: Identifiable, Hashable, Sendable {
    public let id: String
    public var title: String
    public var icon: String

    public init(id: String, title: String, icon: String) {
        self.id = id
        self.title = title
        self.icon = icon
    }
}

/// A floating tab bar with a sliding liquid capsule indicator and spring micro-interactions.
///
/// Usage:
/// ```swift
/// MagneticTabBar(tabs: tabs, selectedTab: $selectedTab)
/// ```
public struct MagneticTabBar: View {
    public var tabs: [TabItem]
    @Binding public var selectedTab: String

    @Namespace private var animationNamespace

    public init(tabs: [TabItem], selectedTab: Binding<String>) {
        self.tabs = tabs
        self._selectedTab = selectedTab
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs) { tab in
                let isSelected = selectedTab == tab.id

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = tab.id
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: isSelected ? .bold : .medium))

                        if isSelected {
                            Text(tab.title)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        }
                    }
                    .foregroundColor(isSelected ? .white : .gray)
                    .padding(.vertical, 10)
                    .padding(.horizontal, isSelected ? 16 : 12)
                    .background(
                        ZStack {
                            if isSelected {
                                Capsule()
                                    .fill(Color.blue)
                                    .matchedGeometryEffect(id: "ActiveTabPill", in: animationNamespace)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.12))
                .overlay(
                    Capsule()
                        .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                )
        )
    }
}
