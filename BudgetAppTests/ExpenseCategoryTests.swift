import XCTest
import SwiftData
import SwiftUI
@testable import BudgetApp

final class CategoryTests: XCTestCase {

    func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Expense.self, MonthlyBudget.self, BudgetCategory.self,
                                  configurations: config)
    }

    func testSeedDefaultsCreates8Categories() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        BudgetCategory.seedDefaults(in: context)

        let descriptor = FetchDescriptor<BudgetCategory>()
        let categories = try context.fetch(descriptor)
        XCTAssertEqual(categories.count, 8)
    }

    func testSeedDefaultsIsIdempotent() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        BudgetCategory.seedDefaults(in: context)
        BudgetCategory.seedDefaults(in: context)

        let descriptor = FetchDescriptor<BudgetCategory>()
        let categories = try context.fetch(descriptor)
        XCTAssertEqual(categories.count, 8)
    }

    func testAllDefaultCategoriesHaveSymbol() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        BudgetCategory.seedDefaults(in: context)

        let descriptor = FetchDescriptor<BudgetCategory>()
        let categories = try context.fetch(descriptor)
        for category in categories {
            XCTAssertFalse(category.symbol.isEmpty,
                           "Category \(category.name) has empty symbol")
        }
    }

    func testAllDefaultCategoriesHaveColor() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        BudgetCategory.seedDefaults(in: context)

        let descriptor = FetchDescriptor<BudgetCategory>()
        let categories = try context.fetch(descriptor)
        for category in categories {
            XCTAssertFalse(category.colorHex.isEmpty,
                           "Category \(category.name) has empty colorHex")
        }
    }

    func testExpectedDefaultNamesExist() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        BudgetCategory.seedDefaults(in: context)

        let descriptor = FetchDescriptor<BudgetCategory>()
        let categories = try context.fetch(descriptor)
        let names = Set(categories.map { $0.name })

        let expected = ["Groceries", "Restaurants", "Car", "Meal Voucher",
                        "Pharmacy", "Bills", "Chico", "Shopping"]
        for name in expected {
            XCTAssertTrue(names.contains(name), "Missing category: \(name)")
        }
    }

    func testCategoryProperties() throws {
        let category = BudgetCategory(name: "Test", symbol: "star.fill", colorHex: "#FF0000", sortOrder: 0)
        XCTAssertEqual(category.name, "Test")
        XCTAssertEqual(category.symbol, "star.fill")
        XCTAssertEqual(category.colorHex, "#FF0000")
        XCTAssertEqual(category.displayName, "Test")
    }
}
