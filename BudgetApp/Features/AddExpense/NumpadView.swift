import SwiftUI

struct NumpadView: View {
    @Binding var amountInCents: Int

    private let buttons: [[NumpadButton]] = [
        [.digit(1), .digit(2), .digit(3)],
        [.digit(4), .digit(5), .digit(6)],
        [.digit(7), .digit(8), .digit(9)],
        [.doubleZero, .digit(0), .backspace],
    ]

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 3),
            spacing: DesignTokens.Padding.inner
        ) {
            ForEach(buttons.flatMap { $0 }) { button in
                NumpadButtonView(button: button, amountInCents: $amountInCents)
            }
        }
        .padding(.horizontal, DesignTokens.Padding.outer)
    }
}

// MARK: - Button model

private enum NumpadButton: Identifiable {
    case digit(Int)
    case doubleZero
    case backspace

    var id: String {
        switch self {
        case .digit(let v): return "digit_\(v)"
        case .doubleZero: return "double_zero"
        case .backspace: return "backspace"
        }
    }
}

// MARK: - Individual button view

private struct NumpadButtonView: View {
    let button: NumpadButton
    @Binding var amountInCents: Int

    var body: some View {
        Button {
            handleTap()
        } label: {
            Group {
                switch button {
                case .digit(let value):
                    Text("\(value)")
                        .font(.title2.weight(.semibold))
                case .doubleZero:
                    Text("00")
                        .font(.title2.weight(.semibold))
                case .backspace:
                    Image(systemName: "delete.backward.fill")
                        .font(.title2)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Color.secondary.opacity(0.15))
            .cornerRadius(DesignTokens.CornerRadius.small)
        }
        .buttonStyle(.plain)
    }

    private func handleTap() {
        switch button {
        case .digit(let value):
            let next = amountInCents * 10 + value
            if next <= 9_999_999 {
                amountInCents = next
            }
            HapticManager.impact()
        case .doubleZero:
            let next = amountInCents * 100
            if next <= 9_999_999 {
                amountInCents = next
            }
            HapticManager.impact()
        case .backspace:
            amountInCents = amountInCents / 10
            HapticManager.selection()
        }
    }
}
