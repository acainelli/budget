import SwiftUI

struct DashboardEmptyState: View {
    let onAddExpense: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "banknote")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No expenses yet this month")
                .font(.headline)
                .foregroundStyle(.secondary)

            Button(action: onAddExpense) {
                Text("Add your first expense")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor, in: Capsule())
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
