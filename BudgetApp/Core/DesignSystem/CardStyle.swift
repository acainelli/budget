import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(20)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
