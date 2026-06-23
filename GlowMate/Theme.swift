import SwiftUI

enum Theme {
    static let page = Color(red: 1.0, green: 0.975, blue: 0.94)
    static let card = Color.white
    static let cardSoft = Color(red: 1.0, green: 0.945, blue: 0.90)
    static let ink = Color(red: 0.18, green: 0.11, blue: 0.09)
    static let secondary = Color(red: 0.50, green: 0.31, blue: 0.25)
    static let muted = Color(red: 0.62, green: 0.40, blue: 0.33)
    static let line = Color(red: 0.75, green: 0.42, blue: 0.30).opacity(0.12)
    static let coral = Color(red: 1.0, green: 0.42, blue: 0.33)
    static let amber = Color(red: 1.0, green: 0.72, blue: 0.26)
    static let success = Color(red: 0.12, green: 0.54, blue: 0.43)
    static let danger = Color(red: 0.76, green: 0.18, blue: 0.16)

    static let primaryGradient = LinearGradient(
        colors: [coral, amber],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func toneColor(_ tone: LightTone) -> Color {
        switch tone {
        case .warmSkin:
            return Color(red: 1.0, green: 0.86, blue: 0.70)
        case .naturalWhite:
            return Color(red: 1.0, green: 0.98, blue: 0.90)
        case .coolWhite:
            return Color(red: 0.88, green: 0.96, blue: 1.0)
        case .blush:
            return Color(red: 1.0, green: 0.79, blue: 0.72)
        }
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Theme.line, lineWidth: 1)
            )
            .shadow(color: Color(red: 0.68, green: 0.30, blue: 0.18).opacity(0.12), radius: 18, x: 0, y: 10)
    }
}

extension View {
    func glowCard() -> some View {
        modifier(CardStyle())
    }
}
