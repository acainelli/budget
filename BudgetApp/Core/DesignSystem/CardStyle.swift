import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(DesignTokens.Padding.outer)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(DesignTokens.CornerRadius.card)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
