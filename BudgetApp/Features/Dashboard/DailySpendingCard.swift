import SwiftUI
import Charts

struct DailySpendingCard: View {
    let expenses: [Expense]
    let currentMonth: Date

    private struct DailyTotal: Identifiable {
        let id = UUID()
        let day: Int
        let total: Double
    }

    private var dailyTotals: [DailyTotal] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: expenses) { expense in
            cal.component(.day, from: expense.date)
        }
        return grouped
            .map { day, items in
                DailyTotal(day: day, total: items.reduce(0) { $0 + $1.amount })
            }
            .sorted { $0.day < $1.day }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Spending")
                .font(.headline)

            if dailyTotals.isEmpty {
                Text("No data")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            } else {
                Chart(dailyTotals) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Amount", item.total)
                    )
                    .foregroundStyle(Color.accentColor)
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel {
                            if let day = value.as(Int.self) {
                                Text("\(day)")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text("€\(Int(amount))")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 180)
            }
        }
        .cardStyle()
    }
}
