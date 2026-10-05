import XCTest
import SwiftUI
@testable import SwiftUIAnimationRecipes

final class SwiftUIAnimationRecipesTests: XCTestCase {

    func testLibraryVersion() {
        XCTAssertEqual(SwiftUIAnimationRecipes.version, "1.0.0")
    }

    func testSpringButtonStyleCreation() {
        let style = SpringPressButtonStyle(scale: 0.92, response: 0.3, dampingFraction: 0.5)
        XCTAssertEqual(style.scale, 0.92, accuracy: 0.001)
        XCTAssertEqual(style.response, 0.3, accuracy: 0.001)
        XCTAssertEqual(style.dampingFraction, 0.5, accuracy: 0.001)
    }

    func testMorphingButtonStates() {
        XCTAssertEqual(MorphingButtonState.idle, .idle)
        XCTAssertNotEqual(MorphingButtonState.idle, .loading)
        XCTAssertNotEqual(MorphingButtonState.loading, .success)
        XCTAssertNotEqual(MorphingButtonState.success, .failure)
    }

    func testSheetDetentsOrder() {
        let detents: [SheetDetent] = [.expanded, .collapsed, .half]
        let sorted = detents.sorted { $0.rawValue < $1.rawValue }
        XCTAssertEqual(sorted, [.collapsed, .half, .expanded])
        XCTAssertEqual(SheetDetent.collapsed.rawValue, 80)
        XCTAssertEqual(SheetDetent.half.rawValue, 340)
        XCTAssertEqual(SheetDetent.expanded.rawValue, 680)
    }

    func testConfettiParticleCreation() {
        let p = ConfettiParticle(x: 10, y: 20, color: .red, size: 8, scale: 1.0)
        XCTAssertEqual(p.x, 10)
        XCTAssertEqual(p.y, 20)
        XCTAssertEqual(p.size, 8)
        XCTAssertEqual(p.scale, 1.0)
    }

    func testTabItemEquality() {
        let tab1 = TabItem(id: "home", title: "Home", icon: "house")
        let tab2 = TabItem(id: "home", title: "Home", icon: "house")
        let tab3 = TabItem(id: "settings", title: "Settings", icon: "gear")

        XCTAssertEqual(tab1, tab2)
        XCTAssertNotEqual(tab1, tab3)
    }
}
