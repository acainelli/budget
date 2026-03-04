import XCTest
@testable import BudgetApp

final class FormatterTests: XCTestCase {

    func testEURGermanFormat() {
        // Critical test: must produce euro prefix, comma decimal (de_DE style)
        XCTAssertEqual(45.8.formattedEUR, "€45,80")
    }

    func testEURGermanFormatWholeNumber() {
        XCTAssertEqual(100.0.formattedEUR, "€100,00")
    }

    func testEURGermanFormatZero() {
        XCTAssertEqual(0.0.formattedEUR, "€0,00")
    }

    func testEURGermanFormatLargeNumber() {
        XCTAssertEqual(1234.56.formattedEUR, "€1.234,56")
    }
}
