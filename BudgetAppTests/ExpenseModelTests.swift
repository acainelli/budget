import XCTest
import SwiftData
@testable import BudgetApp

final class ExpenseModelTests: XCTestCase {

    func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Expense.self, MonthlyBudget.self, BudgetCategory.self,
                                  configurations: config)
    }

    func testMonthYearStoredCorrectly() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 15
        let date = Calendar.current.date(from: components)!

        let category = BudgetCategory(name: "Groceries", symbol: "cart.fill", colorHex: "#34C759", sortOrder: 0)
        context.insert(category)

        let expense = Expense(amount: 45.8, category: category, date: date)
        context.insert(expense)
        try? context.save()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let expected = formatter.string(from: date)

        XCTAssertEqual(expense.monthYear, expected)
        XCTAssertEqual(expense.monthYear, "2026-03")
    }

    func testExpensePropertiesStoredCorrectly() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let category = BudgetCategory(name: "Restaurants", symbol: "fork.knife", colorHex: "#FF9500", sortOrder: 1)
        context.insert(category)

        let date = Date()
        let expense = Expense(amount: 99.99, category: category, date: date, notes: "Dinner")
        context.insert(expense)
        try? context.save()

        XCTAssertEqual(expense.amount, 99.99)
        XCTAssertEqual(expense.category?.name, "Restaurants")
        XCTAssertEqual(expense.notes, "Dinner")
    }

    func testExpenseDefaultNotesIsEmpty() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let category = BudgetCategory(name: "Bills", symbol: "doc.text.fill", colorHex: "#8E8E93", sortOrder: 5)
        context.insert(category)

        let expense = Expense(amount: 10.0, category: category, date: Date())
        context.insert(expense)
        try? context.save()

        XCTAssertEqual(expense.notes, "")
    }

    func testExpenseWithNilCategory() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let expense = Expense(amount: 25.0, category: nil, date: Date())
        context.insert(expense)
        try? context.save()

        XCTAssertNil(expense.category)
    }
}
