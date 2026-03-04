import SwiftUI

struct CategoryIconView: View {
    let category: BudgetCategory?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.categoryIcon)
                .fill(iconColor.opacity(0.2))
                .frame(width: 36, height: 36)
            Image(systemName: category?.symbol ?? "questionmark")
                .font(.body)
                .foregroundStyle(iconColor)
        }
    }

    private var iconColor: Color {
        category?.color ?? .gray
    }
}
