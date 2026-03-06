import SwiftUI
import Charts

struct CategoryBreakdownCard: View {
    let expenses: [Expense]
    @State private var selectedCategoryName: String? = nil

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
                        Button {
                            selectedCategoryName = item.name
                        } label: {
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

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .cardStyle()
        .sheet(item: Binding(
            get: {
                selectedCategoryName.map { name in
                    CategoryExpensesSheet.CategorySelection(
                        name: name,
                        expenses: expenses.filter { ($0.category?.name ?? "Uncategorized") == name }
                    )
                }
            },
            set: { _ in selectedCategoryName = nil }
        )) { selection in
            CategoryExpensesSheet(selection: selection)
        }
    }
}

struct CategoryExpensesSheet: View {
    struct CategorySelection: Identifiable {
        let id = UUID()
        let name: String
        let expenses: [Expense]
    }

    let selection: CategorySelection

    private var sortedExpenses: [Expense] {
        selection.expenses.sorted { $0.date > $1.date }
    }

    private var total: Double {
        selection.expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Total")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(total.formattedEUR)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }

                Section {
                    ForEach(sortedExpenses) { expense in
                        ExpenseRowView(expense: expense)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(selection.name)
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium, .large])
        }
    }
}
