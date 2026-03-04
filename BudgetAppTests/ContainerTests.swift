import XCTest
import SwiftData
@testable import BudgetApp

final class ContainerTests: XCTestCase {

    func testContainerInitWithInMemoryConfig() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        XCTAssertNoThrow(
            try ModelContainer(for: Expense.self, MonthlyBudget.self,
                               configurations: config)
        )
    }

    func testInMemoryContainerCanInsertExpense() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Expense.self, MonthlyBudget.self,
                                           configurations: config)
        let context = ModelContext(container)

        let expense = Expense(amount: 10.0, category: .groceries, date: Date())
        context.insert(expense)
        try context.save()

        let descriptor = FetchDescriptor<Expense>()
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 1)
    }

    func testInMemoryContainerCanInsertMonthlyBudget() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Expense.self, MonthlyBudget.self,
                                           configurations: config)
        let context = ModelContext(container)

        let budget = MonthlyBudget(monthYear: "2026-03")
        context.insert(budget)
        try context.save()

        let descriptor = FetchDescriptor<MonthlyBudget>()
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 1)
    }
}
