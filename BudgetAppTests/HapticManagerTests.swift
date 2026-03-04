import XCTest
@testable import BudgetApp

final class HapticManagerTests: XCTestCase {

    func testImpactDoesNotCrash() {
        XCTAssertNoThrow(HapticManager.impact())
    }

    func testSuccessDoesNotCrash() {
        XCTAssertNoThrow(HapticManager.success())
    }

    func testWarningDoesNotCrash() {
        XCTAssertNoThrow(HapticManager.warning())
    }

    func testSelectionDoesNotCrash() {
        XCTAssertNoThrow(HapticManager.selection())
    }
}
