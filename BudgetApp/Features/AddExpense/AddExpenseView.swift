import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \PaymentTemplate.sortOrder) private var templates: [PaymentTemplate]

    @State private var amountInCents: Int = 0
    @State private var selectedCategory: BudgetCategory?
    @State private var selectedDate: Date = Date()
    @State private var notes: String = ""

    private var canSave: Bool { amountInCents > 0 }

    private var targetMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Amount display
                AmountDisplayView(amountInCents: amountInCents)

                // Custom numpad
                NumpadView(amountInCents: $amountInCents)
                    .padding(.bottom, DesignTokens.Padding.outer)

                // Scrollable bottom section
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignTokens.Padding.outer) {
                        // Payment templates
                        if !templates.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Templates")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, DesignTokens.Padding.outer)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(templates) { template in
                                            Button {
                                                applyTemplate(template)
                                            } label: {
                                                HStack(spacing: 6) {
                                                    if let cat = template.category {
                                                        Image(systemName: cat.symbol)
                                                            .font(.caption)
                                                            .foregroundStyle(cat.color)
                                                    }
                                                    Text(template.name)
                                                        .font(.caption.weight(.medium))
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Color(.secondarySystemBackground))
                                                .cornerRadius(DesignTokens.CornerRadius.small)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, DesignTokens.Padding.outer)
                                }
                            }

                            Divider()
                                .padding(.horizontal, DesignTokens.Padding.outer)
                        }

                        // Category picker
                        Text("Category")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, DesignTokens.Padding.outer)

                        CategoryPickerView(selected: $selectedCategory)

                        Divider()
                            .padding(.horizontal, DesignTokens.Padding.outer)

                        // Date picker
                        VStack(alignment: .leading, spacing: 6) {
                            DatePicker(
                                "Date",
                                selection: $selectedDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .padding(.horizontal, DesignTokens.Padding.outer)

                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                Text(targetMonth)
                                    .font(.footnote)
                            }
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, DesignTokens.Padding.outer)
                        }

                        Divider()
                            .padding(.horizontal, DesignTokens.Padding.outer)

                        // Notes field
                        TextField("Add a note...", text: $notes)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, DesignTokens.Padding.outer)

                        // Save button
                        Button {
                            saveExpense()
                        } label: {
                            Text("Save")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canSave ? Color.green : Color.green.opacity(0.4))
                                .cornerRadius(DesignTokens.CornerRadius.small)
                        }
                        .disabled(!canSave)
                        .padding(.horizontal, DesignTokens.Padding.outer)
                        .padding(.bottom, DesignTokens.Padding.outer)
                    }
                    .padding(.top, DesignTokens.Padding.inner)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func applyTemplate(_ template: PaymentTemplate) {
        amountInCents = template.amountInCents
        selectedCategory = template.category
        notes = template.notes
        HapticManager.selection()
    }

    private func saveExpense() {
        let amount = Double(amountInCents) / 100.0
        let expense = Expense(
            amount: amount,
            category: selectedCategory,
            date: selectedDate,
            notes: notes
        )
        modelContext.insert(expense)
        try? modelContext.save()
        HapticManager.success()
        dismiss()
    }
}
