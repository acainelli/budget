import SwiftUI
import SwiftData

@main
struct BudgetAppApp: App {
    let container: ModelContainer

    init() {
        container = SharedModelContainer.shared
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
