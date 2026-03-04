import SwiftUI

struct AmountDisplayView: View {
    let amountInCents: Int

    private var formattedAmount: String {
        let value = Double(amountInCents) / 100.0
        return value.formattedEUR
    }

    private var isZero: Bool { amountInCents == 0 }

    var body: some View {
        Text(formattedAmount)
            .font(.system(size: 48, weight: .semibold, design: .rounded).monospacedDigit())
            .foregroundStyle(isZero ? Color.secondary : Color.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Padding.outer)
    }
}
