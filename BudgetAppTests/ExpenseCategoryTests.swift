import XCTest
import SwiftData
import SwiftUI
@testable import BudgetApp

final class ExpenseCategoryTests: XCTestCase {

    func testAllCasesExist() {
        XCTAssertEqual(ExpenseCategory.allCases.count, 8)
    }

    func testAllCategoriesHaveSymbol() {
        for category in ExpenseCategory.allCases {
            XCTAssertFalse(category.symbol.isEmpty,
                           "Category \(category.rawValue) has empty symbol")
        }
    }

    func testAllCategoriesHaveColor() {
        for category in ExpenseCategory.allCases {
            // Color should not be clear (a sentinel "no color")
            XCTAssertNotEqual(category.color, Color.clear,
                              "Category \(category.rawValue) has no valid color")
        }
    }

    func testExpectedCasesExist() {
        let expected: [ExpenseCategory] = [
            .groceries, .restaurants, .car, .mealVoucher,
            .pharmacy, .bills, .chico, .shopping
        ]
        for category in expected {
            XCTAssertTrue(ExpenseCategory.allCases.contains(category),
                          "Missing category: \(category.rawValue)")
        }
    }

    func testSpecificSymbols() {
        XCTAssertEqual(ExpenseCategory.groceries.symbol, "cart.fill")
        XCTAssertEqual(ExpenseCategory.restaurants.symbol, "fork.knife")
        XCTAssertEqual(ExpenseCategory.car.symbol, "car.fill")
        XCTAssertEqual(ExpenseCategory.mealVoucher.symbol, "creditcard.fill")
        XCTAssertEqual(ExpenseCategory.pharmacy.symbol, "cross.case.fill")
        XCTAssertEqual(ExpenseCategory.bills.symbol, "doc.text.fill")
        XCTAssertEqual(ExpenseCategory.chico.symbol, "teddybear.fill")
        XCTAssertEqual(ExpenseCategory.shopping.symbol, "bag.fill")
    }
}
