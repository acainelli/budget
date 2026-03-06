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
        Self.seedSampleExpenses(in: context)
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

    private static func seedSampleExpenses(in context: ModelContext) {
        let descriptor = FetchDescriptor<Expense>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        let catDescriptor = FetchDescriptor<BudgetCategory>()
        guard let categories = try? context.fetch(catDescriptor), !categories.isEmpty else { return }
        let catByName = Dictionary(uniqueKeysWithValues: categories.map { ($0.name, $0) })

        let cal = Calendar.current
        let year = 2026

        // (category, note, min cents, max cents)
        let templates: [(String, String, Int, Int)] = [
            ("Groceries",    "Lidl",              1200, 8500),
            ("Groceries",    "Albert Heijn",      800,  6500),
            ("Groceries",    "Aldi",              1500, 4500),
            ("Restaurants",  "Lunch",             900,  1800),
            ("Restaurants",  "Dinner out",        2500, 6500),
            ("Restaurants",  "Coffee",            350,  650),
            ("Car",          "Gas",               4000, 7500),
            ("Car",          "Parking",           200,  1200),
            ("Meal Voucher", "Takeaway lunch",    800,  1400),
            ("Pharmacy",     "Medicine",          500,  3500),
            ("Pharmacy",     "Vitamins",          1200, 2500),
            ("Bills",        "Electricity",       8000, 12000),
            ("Bills",        "Internet",          3500, 3500),
            ("Bills",        "Phone",             2500, 2500),
            ("Chico",        "Dog food",          2000, 4500),
            ("Chico",        "Vet",               4000, 8000),
            ("Shopping",     "Amazon",            1500, 9000),
            ("Shopping",     "Clothes",           2000, 7000),
            ("Shopping",     "Home supplies",     500,  3500),
        ]

        // Simple deterministic pseudo-random using a seed
        var seed: UInt64 = 42

        func nextRandom() -> UInt64 {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return seed >> 33
        }

        func randomInt(_ min: Int, _ max: Int) -> Int {
            guard max > min else { return min }
            return min + Int(nextRandom() % UInt64(max - min + 1))
        }

        // Generate ~25 expenses for each month (Feb and March 2026)
        for month in [2, 3] {
            let daysInMonth = cal.range(of: .day, in: .month, for: cal.date(from: DateComponents(year: year, month: month))!)!.count
            let expenseCount = randomInt(24, 28)

            for _ in 0..<expenseCount {
                let templateIndex = randomInt(0, templates.count - 1)
                let (catName, note, minCents, maxCents) = templates[templateIndex]
                let day = randomInt(1, daysInMonth)
                let cents = randomInt(minCents, maxCents)
                let amount = Double(cents) / 100.0

                guard let date = cal.date(from: DateComponents(year: year, month: month, day: day)) else { continue }
                let category = catByName[catName]
                let expense = Expense(amount: amount, category: category, date: date, notes: note)
                context.insert(expense)
            }
        }

        try? context.save()
    }
}
