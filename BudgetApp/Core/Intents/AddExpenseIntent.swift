import AppIntents
import SwiftData
import Foundation

struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Expense"
    static var description = IntentDescription("Add an expense to BudgetApp")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Amount", description: "Amount in euros (e.g. 12.50)")
    var amount: Double

    @Parameter(title: "Category")
    var category: BudgetCategoryEntity

    @Parameter(title: "Date", description: "Date of the expense")
    var date: Date?

    @Parameter(title: "Notes")
    var notes: String?

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let container = SharedModelContainer.shared
        let context = ModelContext(container)

        let expenseDate = date ?? Date()

        let catID = category.id
        let catDescriptor = FetchDescriptor<BudgetCategory>(
            predicate: #Predicate { $0.id == catID }
        )
        let budgetCategory = try context.fetch(catDescriptor).first

        let expense = Expense(
            amount: amount,
            category: budgetCategory,
            date: expenseDate,
            notes: notes ?? ""
        )
        context.insert(expense)
        try context.save()

        let formatted = amount.formattedEUR
        return .result(value: "Added \(formatted) to \(category.name)")
    }
}
