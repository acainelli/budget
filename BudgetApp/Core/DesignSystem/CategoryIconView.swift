import SwiftUI

struct CategoryIconView: View {
    let category: ExpenseCategory

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(category.color.opacity(0.2))
                .frame(width: 36, height: 36)
            Image(systemName: category.symbol)
                .font(.body)
                .foregroundStyle(category.color)
        }
    }
}
