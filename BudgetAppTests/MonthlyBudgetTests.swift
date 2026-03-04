import XCTest
import SwiftData
@testable import BudgetApp

final class MonthlyBudgetTests: XCTestCase {

    func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Expense.self, MonthlyBudget.self,
                                  configurations: config)
    }

    func testFetchOrCreateIdempotency() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let monthYear = "2026-03"
        let first = MonthlyBudget.fetchOrCreate(monthYear: monthYear, in: context)
        let second = MonthlyBudget.fetchOrCreate(monthYear: monthYear, in: context)

        XCTAssertEqual(first.monthYear, second.monthYear)
        XCTAssertEqual(first.monthYear, monthYear)

        // Verify only one record was created
        let descriptor = FetchDescriptor<MonthlyBudget>()
        let all = try context.fetch(descriptor)
        let matchingRecords = all.filter { $0.monthYear == monthYear }
        XCTAssertEqual(matchingRecords.count, 1)
    }

    func testMonthlyBudgetDefaultIncome() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let budget = MonthlyBudget.fetchOrCreate(monthYear: "2026-01", in: context)
        XCTAssertEqual(budget.income, 0.0)
    }

    func testMonthlyBudgetWithCustomIncome() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let budget = MonthlyBudget(monthYear: "2026-02", income: 3500.0)
        context.insert(budget)
        try? context.save()

        XCTAssertEqual(budget.income, 3500.0)
    }
}
