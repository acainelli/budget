import SwiftUI

struct CategoryPickerView: View {
    @Binding var selected: ExpenseCategory

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 4),
            spacing: DesignTokens.Padding.inner
        ) {
            ForEach(ExpenseCategory.allCases, id: \.self) { category in
                CategoryTileView(category: category, isSelected: selected == category) {
                    selected = category
                    HapticManager.selection()
                }
            }
        }
        .padding(.horizontal, DesignTokens.Padding.outer)
    }
}

// MARK: - Category Tile

private struct CategoryTileView: View {
    let category: ExpenseCategory
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
