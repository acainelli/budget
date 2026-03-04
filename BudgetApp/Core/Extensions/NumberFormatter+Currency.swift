import Foundation

extension NumberFormatter {
    static let eurGerman: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "de_DE")
        f.currencyCode = "EUR"
        // Force euro sign to prefix position per spec ("€45,80" not "45,80 €")
        f.positiveFormat = "€#,##0.00"
        f.negativeFormat = "-€#,##0.00"
        return f
    }()
}

extension Double {
    var formattedEUR: String {
        NumberFormatter.eurGerman.string(from: NSNumber(value: self)) ?? "€0,00"
    }
}
