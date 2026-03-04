import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: DesignTokens.Padding.inner) {
            CategoryIconView(category: expense.category)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category?.displayName ?? "Uncategorized")
                    .font(.subheadline)
                    .fontWeight(.medium)
                if !expense.notes.isEmpty {
                    Text(expense.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(expense.amount.formattedEUR)
                .font(.subheadline)
                .fontWeight(.semibold)
                .monospacedDigit()
                .fontDesign(.rounded)
        }
        .padding(.vertical, 2)
    }
}
