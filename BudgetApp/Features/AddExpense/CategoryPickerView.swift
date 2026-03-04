import SwiftUI
import SwiftData

struct CategoryPickerView: View {
    @Binding var selected: BudgetCategory?
    @Query(sort: \BudgetCategory.sortOrder) private var categories: [BudgetCategory]
    @State private var showAddCategory = false

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 4),
            spacing: DesignTokens.Padding.inner
        ) {
            ForEach(categories) { category in
                CategoryTileView(category: category, isSelected: selected?.id == category.id) {
                    selected = category
                    HapticManager.selection()
                }
            }

            // Add category tile
            Button {
                showAddCategory = true
            } label: {
                VStack(spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.categoryIcon)
                            .fill(Color.secondary.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "plus")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    Text("Add")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(DesignTokens.Padding.inner)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DesignTokens.Padding.outer)
        .sheet(isPresented: $showAddCategory) {
            CategoryFormView(category: nil) { newCategory in
                selected = newCategory
            }
        }
        .onAppear {
            if selected == nil {
                selected = categories.first
            }
        }
    }
}

// MARK: - Category Tile

private struct CategoryTileView: View {
    let category: BudgetCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                CategoryIconView(category: category)
                Text(category.displayName)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(DesignTokens.Padding.inner)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.categoryIcon)
                    .stroke(
                        isSelected ? category.color : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
