import SwiftData
import Foundation
import SwiftUI

@Model
final class Expense {
    var amount: Double = 0.0
    var category: BudgetCategory?
    var date: Date = Date()
    var notes: String = ""
    var monthYear: String = ""
    var legacyCategoryRaw: String?

    init(amount: Double, category: BudgetCategory?, date: Date, notes: String = "") {
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        self.monthYear = formatter.string(from: date)
    }
}
