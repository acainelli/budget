import SwiftData
import Foundation

@Model
final class PaymentTemplate {
    var id: UUID = UUID()
    var name: String = ""
    var amountInCents: Int = 0
    var category: BudgetCategory?
    var notes: String = ""
    var sortOrder: Int = 0

    init(name: String, amountInCents: Int, category: BudgetCategory?, notes: String = "", sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.amountInCents = amountInCents
        self.category = category
        self.notes = notes
        self.sortOrder = sortOrder
    }
}
