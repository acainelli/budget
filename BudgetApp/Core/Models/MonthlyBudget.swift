import SwiftData
import Foundation

@Model
final class MonthlyBudget {
    var monthYear: String
    var income: Double

    init(monthYear: String, income: Double = 0) {
        self.monthYear = monthYear
        self.income = income
    }

    static func fetchOrCreate(monthYear: String, in context: ModelContext) -> MonthlyBudget {
        let descriptor = FetchDescriptor<MonthlyBudget>(
            predicate: #Predicate { $0.monthYear == monthYear }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let budget = MonthlyBudget(monthYear: monthYear)
        context.insert(budget)
        try? context.save()
        return budget
    }
}
