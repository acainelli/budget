import SwiftUI
import SwiftData

struct ManageTemplatesView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \PaymentTemplate.sortOrder) var templates: [PaymentTemplate]
    @Query(sort: \BudgetCategory.sortOrder) var categories: [BudgetCategory]

    @State private var showingAdd = false

    var body: some View {
        List {
            if templates.isEmpty {
                Text("No templates yet. Add one to quickly log recurring expenses.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }

            ForEach(templates) { template in
                NavigationLink(value: template) {
                    TemplateRowView(template: template)
                }
            }
            .onDelete(perform: deleteTemplates)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Payment Templates")
        .navigationDestination(for: PaymentTemplate.self) { template in
            TemplateFormView(template: template)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                TemplateFormView(template: nil)
            }
        }
    }

    private func deleteTemplates(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(templates[index])
        }
        try? modelContext.save()
        HapticManager.warning()
    }
}

private struct TemplateRowView: View {
    let template: PaymentTemplate

    var body: some View {
        HStack(spacing: 12) {
            if let category = template.category {
                CategoryIconView(category: category)
            } else {
                CategoryIconView(category: nil)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.subheadline.weight(.medium))
                if !template.notes.isEmpty {
                    Text(template.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text((Double(template.amountInCents) / 100.0).formattedEUR)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
    }
}

struct TemplateFormView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query(sort: \BudgetCategory.sortOrder) var categories: [BudgetCategory]

    let template: PaymentTemplate?

    @State private var name: String = ""
    @State private var amountInCents: Int = 0
    @State private var selectedCategory: BudgetCategory?
    @State private var notes: String = ""

    private var isEditing: Bool { template != nil }
    private var canSave: Bool { !name.isEmpty && amountInCents > 0 }

    var body: some View {
        Form {
            Section("Template Name") {
                TextField("e.g. Rent", text: $name)
            }

            Section("Amount") {
                HStack {
                    Text("EUR")
                        .foregroundStyle(.secondary)
                    TextField("0,00", text: Binding(
                        get: {
                            amountInCents == 0 ? "" : String(format: "%.2f", Double(amountInCents) / 100.0).replacingOccurrences(of: ".", with: ",")
                        },
                        set: { newValue in
                            let normalized = newValue.replacingOccurrences(of: ",", with: ".")
                            if let value = Double(normalized) {
                                amountInCents = Int(value * 100)
                            }
                        }
                    ))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                }
            }

            Section("Category") {
                Picker("Category", selection: $selectedCategory) {
                    Text("None").tag(nil as BudgetCategory?)
                    ForEach(categories) { category in
                        Label(category.name, systemImage: category.symbol)
                            .tag(category as BudgetCategory?)
                    }
                }
            }

            Section("Notes") {
                TextField("Optional note", text: $notes)
            }
        }
        .navigationTitle(isEditing ? "Edit Template" : "New Template")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(!canSave)
            }
        }
        .onAppear {
            if let template {
                name = template.name
                amountInCents = template.amountInCents
                selectedCategory = template.category
                notes = template.notes
            }
        }
    }

    private func save() {
        if let template {
            template.name = name
            template.amountInCents = amountInCents
            template.category = selectedCategory
            template.notes = notes
        } else {
            let template = PaymentTemplate(
                name: name,
                amountInCents: amountInCents,
                category: selectedCategory,
                notes: notes
            )
            modelContext.insert(template)
        }
        try? modelContext.save()
        HapticManager.success()
        dismiss()
    }
}
