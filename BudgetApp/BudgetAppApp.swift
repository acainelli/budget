import SwiftUI
import SwiftData

@main
struct BudgetAppApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Expense.self, MonthlyBudget.self, BudgetCategory.self)
        } catch {
            // Schema changed — delete old store and recreate (early-stage app)
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: url)
            for ext in ["", "-wal", "-shm"] {
                let sidecar = url.appendingPathExtension(ext)
                try? FileManager.default.removeItem(at: sidecar)
            }
            do {
                container = try ModelContainer(for: Expense.self, MonthlyBudget.self, BudgetCategory.self)
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
        let context = ModelContext(container)
        BudgetCategory.seedDefaults(in: context)
        Self.migrateLegacyCategories(in: context)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }

    private static func migrateLegacyCategories(in context: ModelContext) {
        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate { $0.legacyCategoryRaw != nil }
        )
        guard let expenses = try? context.fetch(descriptor), !expenses.isEmpty else { return }

        let catDescriptor = FetchDescriptor<BudgetCategory>()
        guard let categories = try? context.fetch(catDescriptor) else { return }

        let categoryByName = Dictionary(uniqueKeysWithValues: categories.map { ($0.name.lowercased(), $0) })

        let legacyNameMap: [String: String] = [
            "groceries": "groceries",
            "restaurants": "restaurants",
            "car": "car",
            "mealvoucher": "meal voucher",
            "pharmacy": "pharmacy",
            "bills": "bills",
            "chico": "chico",
            "shopping": "shopping",
        ]

        for expense in expenses {
            if let raw = expense.legacyCategoryRaw {
                let lookupKey = legacyNameMap[raw] ?? raw.lowercased()
                expense.category = categoryByName[lookupKey]
                expense.legacyCategoryRaw = nil
            }
        }
        try? context.save()
    }
}
