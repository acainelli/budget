import SwiftUI
import Charts

struct MonthlyComparisonChart: View {
    let allExpenses: [Expense]
    let currentMonth: Date

    private struct MonthTotal: Identifiable {
        let id = UUID()
        let monthLabel: String
        let monthYear: String
        let total: Double
        let isCurrentMonth: Bool
    }

    private var monthlyTotals: [MonthTotal] {
        let cal = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let monthYearFormatter = DateFormatter()
        monthYearFormatter.dateFormat = "yyyy-MM"

        let currentMonthYear = monthYearFormatter.string(from: currentMonth)

        return (-5...0).compactMap { offset -> MonthTotal? in
            guard let monthDate = cal.date(byAdding: .month, value: offset, to: currentMonth) else { return nil }
            let monthYear = monthYearFormatter.string(from: monthDate)
            let label = formatter.string(from: monthDate)
            let total = allExpenses
                .filter { $0.monthYear == monthYear }
                .reduce(0) { $0 + $1.amount }
            return MonthTotal(
                monthLabel: label,
                monthYear: monthYear,
                total: total,
                isCurrentMonth: monthYear == currentMonthYear
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("6-Month Comparison")
                .font(.headline)

            Chart(monthlyTotals) { item in
                BarMark(
                    x: .value("Month", item.monthLabel),
                    y: .value("Total", item.total)
                )
                .foregroundStyle(item.isCurrentMonth ? Color.accentColor : Color.secondary.opacity(0.5))
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(amount.formattedEUR)
                                .font(.caption2)
                        }
                    }
                    AxisGridLine()
                }
            }
            .frame(height: 200)
        }
    }
}
