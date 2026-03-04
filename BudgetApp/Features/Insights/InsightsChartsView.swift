import SwiftUI
import Charts

struct InsightsChartsView: View {
    let expenses: [Expense]
    let allExpenses: [Expense]
    let currentMonth: Date

    private struct CategoryTotal: Identifiable {
        let id: String
        let name: String
        let color: Color
        let total: Double
    }

    private var categoryTotals: [CategoryTotal] {
        let grouped = Dictionary(grouping: expenses) { $0.category?.name ?? "Uncategorized" }
        return grouped
            .compactMap { name, items -> CategoryTotal? in
                let total = items.reduce(0) { $0 + $1.amount }
                guard total > 0 else { return nil }
                let color = items.first?.category?.color ?? .gray
                return CategoryTotal(id: name, name: name, color: color, total: total)
            }
            .sorted { $0.total > $1.total }
    }

    private var grandTotal: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Category pie chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Spending by Category")
                        .font(.headline)

                    if categoryTotals.isEmpty {
                        Text("No data")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    } else {
                        ZStack {
                            Chart(categoryTotals) { item in
                                SectorMark(
                                    angle: .value("Amount", item.total),
                                    innerRadius: .ratio(0.6),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(item.color)
                            }
                            .frame(height: 250)

                            VStack(spacing: 2) {
                                Text(grandTotal.formattedEUR)
                                    .font(.caption.weight(.semibold))
                                Text("total")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(categoryTotals) { item in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(item.color)
                                        .frame(width: 10, height: 10)
                                    Text(item.name)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(item.total.formattedEUR)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }
                .cardStyle()

                // Spending trend chart
                SpendingTrendChart(expenses: expenses, currentMonth: currentMonth)
                    .cardStyle()

                // 6-month comparison chart
                MonthlyComparisonChart(allExpenses: allExpenses, currentMonth: currentMonth)
                    .cardStyle()
            }
            .padding(.horizontal, DesignTokens.Padding.outer)
            .padding(.vertical, DesignTokens.Padding.inner)
        }
    }
}
