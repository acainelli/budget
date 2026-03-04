import SwiftData
import Foundation
import SwiftUI

@Model
final class BudgetCategory {
    var id: UUID = UUID()
    var name: String = ""
    var symbol: String = "questionmark"
    var colorHex: String = "#808080"
    var sortOrder: Int = 0
    var isDefault: Bool = false

    @Relationship(deleteRule: .nullify, inverse: \Expense.category)
    var expenses: [Expense] = []

    var color: Color {
        Color(hex: colorHex)
    }

    var displayName: String {
        name
    }

    init(name: String, symbol: String, colorHex: String, sortOrder: Int, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.symbol = symbol
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.isDefault = isDefault
    }

    static func seedDefaults(in context: ModelContext) {
        let descriptor = FetchDescriptor<BudgetCategory>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        let defaults: [(String, String, String)] = [
            ("Groceries",    "cart.fill",         "#34C759"),
            ("Restaurants",  "fork.knife",        "#FF9500"),
            ("Car",          "car.fill",          "#007AFF"),
            ("Meal Voucher", "creditcard.fill",   "#AF52DE"),
            ("Pharmacy",     "cross.case.fill",   "#FF3B30"),
            ("Bills",        "doc.text.fill",     "#8E8E93"),
            ("Chico",        "teddybear.fill",    "#A2845E"),
            ("Shopping",     "bag.fill",          "#FF2D55"),
        ]

        for (index, (name, symbol, hex)) in defaults.enumerated() {
            let category = BudgetCategory(name: name, symbol: symbol, colorHex: hex, sortOrder: index, isDefault: true)
            context.insert(category)
        }

        try? context.save()
    }
}
