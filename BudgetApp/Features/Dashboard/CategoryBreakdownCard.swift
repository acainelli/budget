import SwiftUI
import Charts

struct CategoryBreakdownCard: View {
    let expenses: [Expense]

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
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)

            if categoryTotals.isEmpty {
                Text("No data")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                // Donut chart
                ZStack {
                    Chart(categoryTotals) { item in
                        SectorMark(
                            angle: .value("Amount", item.total),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(item.color)
                    }
                    .frame(height: 200)

                    // Center label
                    VStack(spacing: 2) {
                        Text(grandTotal.formattedEUR)
                            .font(.caption.weight(.semibold))
                        Text("total")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                // Legend
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
    }
}
