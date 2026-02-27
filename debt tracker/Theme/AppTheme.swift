import SwiftUI

enum AppTheme {
    static let cardCornerRadius: CGFloat = 20
    static let smallCornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 16
    static let screenPadding: CGFloat = 20
    static let cardShadow: Color = .black.opacity(0.3)
    static let cardShadowRadius: CGFloat = 10
}

// MARK: - Card Background Modifier

struct CardBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(ColorTokens.surface)
                    .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, y: 4)
            )
    }
}

// MARK: - Pressable Button Style

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(AppAnimations.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        modifier(CardBackgroundModifier())
    }

    func pressable() -> some View {
        buttonStyle(PressableButtonStyle())
    }
}
