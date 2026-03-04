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
                Button {
                    editingCategory = category
                } label: {
                    HStack(spacing: 12) {
                        CategoryIconView(category: category)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(category.displayName)
                                .font(.body)
                                .foregroundStyle(.primary)
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
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        categoryToDelete = category
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
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

    private func deleteCategory(_ category: BudgetCategory) {
        modelContext.delete(category)
        try? modelContext.save()
        HapticManager.warning()
        categoryToDelete = nil
    }
}
