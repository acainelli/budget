import SwiftUI
import Charts

struct SpendingTrendChart: View {
    let expenses: [Expense]
    let currentMonth: Date

    private struct DayTotal: Identifiable {
        let id = UUID()
        let date: Date
        let total: Double
    }

    private var dailyTotals: [DayTotal] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: currentMonth),
              let firstDay = cal.date(from: cal.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        // Group expenses by start of day
        var grouped: [Date: Double] = [:]
        for expense in expenses {
            let day = cal.startOfDay(for: expense.date)
            grouped[day, default: 0] += expense.amount
        }

        // Fill all days in the month
        return range.compactMap { dayOffset -> DayTotal? in
            guard let date = cal.date(byAdding: .day, value: dayOffset - 1, to: firstDay) else { return nil }
            let dayStart = cal.startOfDay(for: date)
            return DayTotal(date: dayStart, total: grouped[dayStart] ?? 0)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending Trend")
                .font(.headline)

            if dailyTotals.isEmpty {
                Text("No data")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                Chart(dailyTotals) { item in
                    AreaMark(
                        x: .value("Day", item.date),
                        y: .value("Amount", item.total)
                    )
                    .foregroundStyle(Color.accentColor.opacity(0.1))
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Day", item.date),
                        y: .value("Amount", item.total)
                    )
                    .foregroundStyle(Color.accentColor)
                    .interpolationMethod(.catmullRom)
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
}
