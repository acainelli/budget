import SwiftUI

struct DayExpensesSheet: View {
    let day: Date
    let expenses: [Expense]

    @Environment(\.dismiss) private var dismiss

    private var dayTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: day)
    }

    private var dailyTotal: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            List {
                // Daily total header
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text(dailyTotal.formattedEUR)
                                .font(.largeTitle.weight(.bold))
                            Text("Total for the day")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                // Expense rows
                if expenses.isEmpty {
                    Section {
                        Text("No expenses")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                } else {
                    Section("Expenses") {
                        ForEach(expenses.sorted { $0.date < $1.date }) { expense in
                            HStack(spacing: 12) {
                                CategoryIconView(category: expense.category)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(expense.category?.displayName ?? "Uncategorized")
                                        .font(.subheadline.weight(.medium))
                                    if !expense.notes.isEmpty {
                                        Text(expense.notes)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }

                                Spacer()

                                Text(expense.amount.formattedEUR)
                                    .font(.subheadline.weight(.semibold))
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle(dayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
