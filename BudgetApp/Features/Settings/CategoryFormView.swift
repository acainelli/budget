import SwiftUI
import SwiftData

struct CategoryFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let category: BudgetCategory?
    var onSave: ((BudgetCategory) -> Void)?

    @State private var name: String
    @State private var selectedSymbol: String
    @State private var selectedColorHex: String

    private let symbolOptions = [
        "cart.fill", "fork.knife", "car.fill", "creditcard.fill",
        "cross.case.fill", "doc.text.fill", "teddybear.fill", "bag.fill",
        "house.fill", "airplane", "bus.fill", "fuelpump.fill",
        "gift.fill", "heart.fill", "star.fill", "leaf.fill",
        "cup.and.saucer.fill", "gamecontroller.fill", "music.note",
        "book.fill", "graduationcap.fill", "dumbbell.fill",
        "pawprint.fill", "scissors", "wrench.fill", "paintbrush.fill",
        "camera.fill", "phone.fill", "wifi", "lightbulb.fill",
    ]

    private let colorOptions = [
        "#34C759", "#FF9500", "#007AFF", "#AF52DE",
        "#FF3B30", "#8E8E93", "#A2845E", "#FF2D55",
        "#5AC8FA", "#FFCC00", "#64D2FF", "#30D158",
    ]

    private var isEditing: Bool { category != nil }

    init(category: BudgetCategory?, onSave: ((BudgetCategory) -> Void)? = nil) {
        self.category = category
        self.onSave = onSave
        _name = State(initialValue: category?.name ?? "")
        _selectedSymbol = State(initialValue: category?.symbol ?? "cart.fill")
        _selectedColorHex = State(initialValue: category?.colorHex ?? "#34C759")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category name", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(symbolOptions, id: \.self) { symbol in
                            Button {
                                selectedSymbol = symbol
                                HapticManager.selection()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedSymbol == symbol ? Color(hex: selectedColorHex).opacity(0.2) : Color.secondary.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: symbol)
                                        .font(.body)
                                        .foregroundStyle(selectedSymbol == symbol ? Color(hex: selectedColorHex) : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Button {
                                selectedColorHex = hex
                                HapticManager.selection()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 36, height: 36)
                                    if selectedColorHex == hex {
                                        Circle()
                                            .strokeBorder(.white, lineWidth: 3)
                                            .frame(width: 36, height: 36)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.categoryIcon)
                                    .fill(Color(hex: selectedColorHex).opacity(0.2))
                                    .frame(width: 48, height: 48)
                                Image(systemName: selectedSymbol)
                                    .font(.title3)
                                    .foregroundStyle(Color(hex: selectedColorHex))
                            }
                            Text(name.isEmpty ? "Preview" : name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle(isEditing ? "Edit Category" : "New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if let existing = category {
            existing.name = trimmedName
            existing.symbol = selectedSymbol
            existing.colorHex = selectedColorHex
            try? modelContext.save()
            onSave?(existing)
        } else {
            let descriptor = FetchDescriptor<BudgetCategory>(sortBy: [SortDescriptor(\.sortOrder, order: .reverse)])
            let maxOrder = (try? modelContext.fetch(descriptor).first?.sortOrder) ?? -1
            let newCategory = BudgetCategory(
                name: trimmedName,
                symbol: selectedSymbol,
                colorHex: selectedColorHex,
                sortOrder: maxOrder + 1
            )
            modelContext.insert(newCategory)
            try? modelContext.save()
            onSave?(newCategory)
        }
        HapticManager.success()
        dismiss()
    }
}
