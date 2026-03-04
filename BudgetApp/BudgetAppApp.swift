import SwiftUI
import SwiftData

@main
struct BudgetAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Expense.self,
            MonthlyBudget.self,
        ])
    }
}
