import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    let expense: Expense

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var editedDate: Date
    @State private var editedNotes: String
    @State private var showDeleteConfirmation = false

    private let monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f
    }()

    init(expense: Expense) {
        self.expense = expense
        _editedDate = State(initialValue: expense.date)
        _editedNotes = State(initialValue: expense.notes)
    }

    var body: some View {
        List {
            // Header section: icon, category, amount
            Section {
                VStack(spacing: DesignTokens.Padding.inner) {
                    CategoryIconView(category: expense.category)
                        .scaleEffect(2.0)
                        .padding(.top, DesignTokens.Padding.outer)
                        .padding(.bottom, DesignTokens.Padding.inner)
                    Text(expense.category?.displayName ?? "Uncategorized")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(expense.amount.formattedEUR)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Padding.inner)
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
        .onChange(of: editedDate) { _, newDate in
            expense.date = newDate
            expense.monthYear = monthYearFormatter.string(from: newDate)
            try? modelContext.save()
        }
        .onChange(of: editedNotes) { _, newNotes in
            expense.notes = newNotes
            try? modelContext.save()
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
