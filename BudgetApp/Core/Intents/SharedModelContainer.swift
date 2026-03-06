import SwiftData
import Foundation

enum SharedModelContainer {
    static let shared: ModelContainer = {
        do {
            return try ModelContainer(for: Expense.self, MonthlyBudget.self, BudgetCategory.self, PaymentTemplate.self)
        } catch {
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: url)
            for ext in ["", "-wal", "-shm"] {
                let sidecar = url.appendingPathExtension(ext)
                try? FileManager.default.removeItem(at: sidecar)
            }
            do {
                return try ModelContainer(for: Expense.self, MonthlyBudget.self, BudgetCategory.self, PaymentTemplate.self)
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
    }()
}
