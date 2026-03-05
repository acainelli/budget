import SwiftUI
import SwiftData

struct ManageCategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BudgetCategory.sortOrder) private var categories: [BudgetCategory]

    @State private var showAddForm = false
    @State private var editingCategory: BudgetCategory?
    @State private var categoryToDelete: BudgetCategory?

    var body: some View {
        List {
            ForEach(categories) { category in
                CategoryRow(category: category, onEdit: {
                    editingCategory = category
                })
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        categoryToDelete = category
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        toggleVisibility(category)
                    } label: {
                        Label(
                            category.isHiddenFromStats ? "Show" : "Hide",
                            systemImage: category.isHiddenFromStats ? "eye" : "eye.slash"
                        )
                    }
                    .tint(category.isHiddenFromStats ? .green : .orange)
                }
            }
            .onMove { from, to in
                var ordered = categories.map { $0 }
                ordered.move(fromOffsets: from, toOffset: to)
                for (index, cat) in ordered.enumerated() {
                    cat.sortOrder = index
                }
                try? modelContext.save()
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddForm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddForm) {
            CategoryFormView(category: nil)
        }
        .sheet(item: $editingCategory) { category in
            CategoryFormView(category: category)
        }
        .alert(
            "Delete \(categoryToDelete?.name ?? "Category")?",
            isPresented: Binding(
                get: { categoryToDelete != nil },
                set: { if !$0 { categoryToDelete = nil } }
            )
        ) {
            Button("Delete", role: .destructive) {
                if let cat = categoryToDelete {
                    deleteCategory(cat)
                }
            }
            Button("Cancel", role: .cancel) {
                categoryToDelete = nil
            }
        } message: {
            if let cat = categoryToDelete, !cat.expenses.isEmpty {
                Text("\(cat.expenses.count) expense\(cat.expenses.count == 1 ? "" : "s") will become Uncategorized.")
            } else {
                Text("This category will be permanently deleted.")
            }
        }
    }

    private func toggleVisibility(_ category: BudgetCategory) {
        category.isHiddenFromStats.toggle()
        try? modelContext.save()
        HapticManager.impact()
    }

    private func deleteCategory(_ category: BudgetCategory) {
        modelContext.delete(category)
        try? modelContext.save()
        HapticManager.warning()
        categoryToDelete = nil
    }
}

private struct CategoryRow: View {
    let category: BudgetCategory
    let onEdit: () -> Void

    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 12) {
                CategoryIconView(category: category)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(category.displayName)
                            .font(.body)
                            .foregroundStyle(category.isHiddenFromStats ? .secondary : .primary)
                        if category.isHiddenFromStats {
                            Image(systemName: "eye.slash")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    if category.isDefault {
                        Text("Default")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                let count = category.expenses.count
                if count > 0 {
                    Text("\(count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1), in: Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}
