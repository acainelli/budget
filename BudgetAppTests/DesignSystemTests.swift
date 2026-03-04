import XCTest
import SwiftUI
@testable import BudgetApp

final class DesignSystemTests: XCTestCase {

    func testCardStyleTokens() {
        XCTAssertEqual(DesignTokens.CornerRadius.card, 20)
        XCTAssertEqual(DesignTokens.CornerRadius.small, 12)
        XCTAssertEqual(DesignTokens.Padding.outer, 16)
        XCTAssertEqual(DesignTokens.Padding.inner, 8)
    }

    func testFABSizeToken() {
        XCTAssertEqual(DesignTokens.FAB.size, 56)
    }

    func testCategoryIconCornerRadiusToken() {
        XCTAssertEqual(DesignTokens.CornerRadius.categoryIcon, 8)
    }

    func testCardStyleModifierExists() {
        // Compile-time test: verifies .cardStyle() can be called on a View
        XCTAssertNoThrow({
            let _ = Text("Test").cardStyle()
        }())
    }
}
