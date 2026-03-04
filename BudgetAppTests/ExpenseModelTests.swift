import XCTest
import SwiftData
@testable import BudgetApp

final class ExpenseModelTests: XCTestCase {

    func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Expense.self, MonthlyBudget.self,
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

        let expense = Expense(amount: 45.8, category: .groceries, date: date)
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

        let date = Date()
        let expense = Expense(amount: 99.99, category: .restaurants, date: date, notes: "Dinner")
        context.insert(expense)
        try? context.save()

        XCTAssertEqual(expense.amount, 99.99)
        XCTAssertEqual(expense.category, .restaurants)
        XCTAssertEqual(expense.notes, "Dinner")
    }

    func testExpenseDefaultNotesIsEmpty() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let expense = Expense(amount: 10.0, category: .bills, date: Date())
        context.insert(expense)
        try? context.save()

        XCTAssertEqual(expense.notes, "")
    }
}
