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

        // Simple deterministic pseudo-random
        var seed: UInt64 = 42
        func nextRandom() -> UInt64 {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return seed >> 33
        }
        func randomInt(_ min: Int, _ max: Int) -> Int {
            guard max > min else { return min }
            return min + Int(nextRandom() % UInt64(max - min + 1))
        }

        func addExpense(_ cat: String, _ note: String, _ cents: Int, month: Int, day: Int) {
            guard let date = cal.date(from: DateComponents(year: 2026, month: month, day: day)) else { return }
            let expense = Expense(amount: Double(cents) / 100.0, category: catByName[cat], date: date, notes: note)
            context.insert(expense)
        }

        // ── February 2026 (~€1,950) ──

        // Bills (fixed, start of month)
        addExpense("Bills",        "Rent",           85000, month: 2, day: 1)
        addExpense("Bills",        "Electricity",     9500, month: 2, day: 3)
        addExpense("Bills",        "Internet",        3500, month: 2, day: 3)
        addExpense("Bills",        "Phone plan",      2500, month: 2, day: 5)

        // Groceries (2x per week)
        addExpense("Groceries",    "Lidl",            4520, month: 2, day: 2)
        addExpense("Groceries",    "Albert Heijn",    3180, month: 2, day: 6)
        addExpense("Groceries",    "Lidl",            5240, month: 2, day: 9)
        addExpense("Groceries",    "Aldi",            2890, month: 2, day: 13)
        addExpense("Groceries",    "Albert Heijn",    6150, month: 2, day: 16)
        addExpense("Groceries",    "Lidl",            3470, month: 2, day: 20)
        addExpense("Groceries",    "Albert Heijn",    4810, month: 2, day: 23)
        addExpense("Groceries",    "Aldi",            3920, month: 2, day: 27)

        // Restaurants / Coffee
        addExpense("Restaurants",  "Coffee",           450, month: 2, day: 4)
        addExpense("Restaurants",  "Lunch with team", 1350, month: 2, day: 7)
        addExpense("Restaurants",  "Dinner out",      4200, month: 2, day: 14)
        addExpense("Restaurants",  "Coffee",           480, month: 2, day: 18)
        addExpense("Restaurants",  "Brunch",          2800, month: 2, day: 22)

        // Car
        addExpense("Car",          "Gas",             5800, month: 2, day: 8)
        addExpense("Car",          "Parking",          350, month: 2, day: 12)
        addExpense("Car",          "Gas",             6200, month: 2, day: 24)

        // Meal Voucher
        addExpense("Meal Voucher", "Takeaway lunch",  1050, month: 2, day: 10)
        addExpense("Meal Voucher", "Takeaway lunch",  1180, month: 2, day: 17)
        addExpense("Meal Voucher", "Takeaway lunch",   950, month: 2, day: 25)

        // Pharmacy
        addExpense("Pharmacy",     "Ibuprofen",        680, month: 2, day: 11)

        // Chico
        addExpense("Chico",        "Dog food",        3200, month: 2, day: 15)
        addExpense("Chico",        "Toys",            1450, month: 2, day: 21)

        // Shopping
        addExpense("Shopping",     "Amazon",          2490, month: 2, day: 19)
        addExpense("Shopping",     "Winter jacket",   5990, month: 2, day: 26)

        // ── March 2026 (~€2,080) ──

        // Bills
        addExpense("Bills",        "Rent",           85000, month: 3, day: 1)
        addExpense("Bills",        "Electricity",    10200, month: 3, day: 2)
        addExpense("Bills",        "Internet",        3500, month: 3, day: 2)
        addExpense("Bills",        "Phone plan",      2500, month: 3, day: 5)

        // Groceries
        addExpense("Groceries",    "Lidl",            3980, month: 3, day: 1)
        addExpense("Groceries",    "Albert Heijn",    5620, month: 3, day: 5)
        addExpense("Groceries",    "Aldi",            2750, month: 3, day: 8)
        addExpense("Groceries",    "Lidl",            4310, month: 3, day: 12)
        addExpense("Groceries",    "Albert Heijn",    3690, month: 3, day: 15)
        addExpense("Groceries",    "Lidl",            5870, month: 3, day: 19)
        addExpense("Groceries",    "Aldi",            2940, month: 3, day: 22)
        addExpense("Groceries",    "Albert Heijn",    4150, month: 3, day: 26)
        addExpense("Groceries",    "Lidl",            3280, month: 3, day: 29)

        // Restaurants / Coffee
        addExpense("Restaurants",  "Coffee",           420, month: 3, day: 3)
        addExpense("Restaurants",  "Lunch",           1280, month: 3, day: 6)
        addExpense("Restaurants",  "Coffee",           520, month: 3, day: 11)
        addExpense("Restaurants",  "Pizza night",     3500, month: 3, day: 14)
        addExpense("Restaurants",  "Coffee",           450, month: 3, day: 20)
        addExpense("Restaurants",  "Dinner out",      5200, month: 3, day: 28)

        // Car
        addExpense("Car",          "Gas",             6400, month: 3, day: 4)
        addExpense("Car",          "Car wash",         800, month: 3, day: 10)
        addExpense("Car",          "Parking",          500, month: 3, day: 17)
        addExpense("Car",          "Gas",             5900, month: 3, day: 25)

        // Meal Voucher
        addExpense("Meal Voucher", "Takeaway lunch",  1100, month: 3, day: 7)
        addExpense("Meal Voucher", "Takeaway lunch",  1250, month: 3, day: 13)
        addExpense("Meal Voucher", "Takeaway lunch",   980, month: 3, day: 24)

        // Pharmacy
        addExpense("Pharmacy",     "Vitamins",        1890, month: 3, day: 9)
        addExpense("Pharmacy",     "Allergy meds",     950, month: 3, day: 21)

        // Chico
        addExpense("Chico",        "Dog food",        3400, month: 3, day: 16)
        addExpense("Chico",        "Vet checkup",     6500, month: 3, day: 23)

        // Shopping
        addExpense("Shopping",     "Amazon",          3290, month: 3, day: 18)
        addExpense("Shopping",     "Running shoes",   7990, month: 3, day: 27)

        try? context.save()
    }
}
