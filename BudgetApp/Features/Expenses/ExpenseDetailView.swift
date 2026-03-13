import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    let expense: Expense

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var editedAmountInCents: Int
    @State private var editedCategory: BudgetCategory?
    @State private var editedDate: Date
    @State private var editedNotes: String
    @State private var showDeleteConfirmation = false
    @State private var isEditingAmount = false

    private let monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f
    }()

    init(expense: Expense) {
        self.expense = expense
        _editedAmountInCents = State(initialValue: Int(round(expense.amount * 100)))
        _editedCategory = State(initialValue: expense.category)
        _editedDate = State(initialValue: expense.date)
        _editedNotes = State(initialValue: expense.notes)
    }

    private var displayAmount: String {
        let value = Double(editedAmountInCents) / 100.0
        return value.formattedEUR
    }

    var body: some View {
        List {
            // Header section: icon, category, amount
            Section {
                VStack(spacing: DesignTokens.Padding.inner) {
                    CategoryIconView(category: editedCategory)
                        .scaleEffect(2.0)
                        .padding(.top, DesignTokens.Padding.outer)
                        .padding(.bottom, DesignTokens.Padding.inner)
                    Text(editedCategory?.displayName ?? "Uncategorized")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Button {
                        isEditingAmount = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(displayAmount)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .monospacedDigit()
                                .foregroundStyle(.primary)
                            Image(systemName: "pencil.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Padding.inner)
            }

            // Category picker
            Section("Category") {
                CategoryPickerView(selected: $editedCategory)
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
            }

            // Editable fields
            Section("Details") {
                DatePicker(
                    "Date",
                    selection: $editedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)

                HStack {
                    Text("Notes")
                    Spacer()
                    TextField("Add notes", text: $editedNotes)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                }
            }

            // Delete section
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete Expense")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Expense Details")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: editedAmountInCents) { _, newAmount in
            expense.amount = Double(newAmount) / 100.0
            try? modelContext.save()
        }
        .onChange(of: editedCategory) { _, newCategory in
            expense.category = newCategory
            try? modelContext.save()
        }
        .onChange(of: editedDate) { _, newDate in
            expense.date = newDate
            expense.monthYear = monthYearFormatter.string(from: newDate)
            try? modelContext.save()
        }
        .onChange(of: editedNotes) { _, newNotes in
            expense.notes = newNotes
            try? modelContext.save()
        }
        .sheet(isPresented: $isEditingAmount) {
            EditAmountSheet(amountInCents: $editedAmountInCents)
        }
        .alert("Delete Expense", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                HapticManager.warning()
                modelContext.delete(expense)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This expense will be permanently deleted.")
        }
    }
}

// MARK: - Edit Amount Sheet

private struct EditAmountSheet: View {
    @Binding var amountInCents: Int
    @Environment(\.dismiss) private var dismiss

    @State private var editingCents: Int

    init(amountInCents: Binding<Int>) {
        _amountInCents = amountInCents
        _editingCents = State(initialValue: amountInCents.wrappedValue)
    }

    private var displayAmount: String {
        let value = Double(editingCents) / 100.0
        return value.formattedEUR
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AmountDisplayView(amountInCents: editingCents)

                NumpadView(amountInCents: $editingCents)
                    .padding(.bottom, DesignTokens.Padding.outer)

                Button {
                    amountInCents = editingCents
                    HapticManager.success()
                    dismiss()
                } label: {
                    Text("Update Amount")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(editingCents > 0 ? Color.green : Color.green.opacity(0.4))
                        .cornerRadius(DesignTokens.CornerRadius.small)
                }
                .disabled(editingCents == 0)
                .padding(.horizontal, DesignTokens.Padding.outer)
                .padding(.bottom, DesignTokens.Padding.outer)
            }
            .navigationTitle("Edit Amount")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
