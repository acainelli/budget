import SwiftData
import Foundation
import SwiftUI

@Model
final class Expense {
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var notes: String
    var monthYear: String

    init(amount: Double, category: ExpenseCategory, date: Date, notes: String = "") {
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        self.monthYear = formatter.string(from: date)
    }
}

enum ExpenseCategory: String, CaseIterable, Codable {
    case groceries
    case restaurants
    case car
    case mealVoucher
    case pharmacy
    case bills
    case chico
    case shopping

    var symbol: String {
        switch self {
        case .groceries:   return "cart.fill"
        case .restaurants: return "fork.knife"
        case .car:         return "car.fill"
        case .mealVoucher: return "creditcard.fill"
        case .pharmacy:    return "cross.case.fill"
        case .bills:       return "doc.text.fill"
        case .chico:       return "teddybear.fill"
        case .shopping:    return "bag.fill"
        }
    }

    var color: Color {
        switch self {
        case .groceries:   return Color(uiColor: .systemGreen)
        case .restaurants: return Color(uiColor: .systemOrange)
        case .car:         return Color(uiColor: .systemBlue)
        case .mealVoucher: return Color(uiColor: .systemPurple)
        case .pharmacy:    return Color(uiColor: .systemRed)
        case .bills:       return Color(uiColor: .systemGray)
        case .chico:       return Color(uiColor: .brown)
        case .shopping:    return Color(uiColor: .systemPink)
        }
    }

    var displayName: String { rawValue.capitalized }
}
