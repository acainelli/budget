import SwiftUI
import SwiftData

enum BulkDeleteScope: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
}

struct BulkDeleteSheet: View {
    let allExpenses: [Expense]

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var scope: BulkDeleteScope = .day
    @State private var showConfirmation = false

    private var expensesToDelete: [Expense] {
        let calendar = Calendar.current
        switch scope {
        case .day:
            return allExpenses.filter { calendar.isDateInToday($0.date) }
        case .week:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
            return allExpenses.filter { interval.contains($0.date) }
        case .month:
            guard let interval = calendar.dateInterval(of: .month, for: Date()) else { return [] }
            return allExpenses.filter { interval.contains($0.date) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Scope", selection: $scope) {
                        ForEach(BulkDeleteScope.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section {
                    HStack {
                        Spacer()
                        Text("\(expensesToDelete.count) expense\(expensesToDelete.count == 1 ? "" : "s") will be deleted")
                            .font(.headline)
                            .foregroundStyle(expensesToDelete.isEmpty ? .secondary : .primary)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }

                if !expensesToDelete.isEmpty {
                    Section("Preview") {
                        ForEach(expensesToDelete) { expense in
                            HStack(spacing: DesignTokens.Padding.inner) {
                                CategoryIconView(category: expense.category)
                                Text(expense.category.displayName)
                                    .font(.caption)
                                Spacer()
                                Text(expense.amount.formattedEUR)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .monospacedDigit()
                            }
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        if !expensesToDelete.isEmpty {
                            showConfirmation = true
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete \(expensesToDelete.count) Expense\(expensesToDelete.count == 1 ? "" : "s")")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(expensesToDelete.isEmpty)
                }
            }
            .navigationTitle("Bulk Delete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .confirmationDialog(
                "Delete \(expensesToDelete.count) expense\(expensesToDelete.count == 1 ? "" : "s")?",
                isPresented: $showConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete \(expensesToDelete.count) Expense\(expensesToDelete.count == 1 ? "" : "s")", role: .destructive) {
                    let toDelete = expensesToDelete
                    for expense in toDelete {
                        modelContext.delete(expense)
                    }
                    try? modelContext.save()
                    HapticManager.warning()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
        }
    }
}
