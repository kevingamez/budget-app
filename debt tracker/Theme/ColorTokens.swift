import SwiftUI

/// Public color API used throughout the app.
/// Values are derived from the active `AppThemePalette` so that
/// switching the theme via `ThemeManager` updates every call site.
enum ColorTokens {
    private static var theme: AppThemePalette { ThemeManager.shared.current }

    // MARK: - Backgrounds
    static var background: Color { theme.background }
    static var surface: Color { theme.surface }
    static var surfaceElevated: Color { theme.surfaceElevated }
    static var surfaceBorder: Color { theme.surfaceBorder }

    // MARK: - Accent Gradients
    static var primaryGradient: LinearGradient { theme.primaryGradient }
    static var greenGradient: LinearGradient { theme.greenGradient }
    static var redGradient: LinearGradient { theme.redGradient }
    static var goldGradient: LinearGradient { theme.goldGradient }

    // MARK: - Flat Accents
    static var primaryAccent: Color { theme.primaryAccent }
    static var green: Color { theme.green }
    static var red: Color { theme.red }
    static var gold: Color { theme.gold }

    // MARK: - Text
    static var textPrimary: Color { theme.textPrimary }
    static var textSecondary: Color { theme.textSecondary }
    static var textTertiary: Color { theme.textTertiary }

    // MARK: - Semantic
    static var owedToMeColor: Color { theme.green }
    static var iOweColor: Color { theme.red }
    static var overdueColor: Color { theme.overdue }

    // MARK: - Helpers
    static func gradientForDirection(_ direction: DebtDirection) -> LinearGradient {
        switch direction {
        case .owedToMe: greenGradient
        case .iOwe: redGradient
        }
    }

    static func colorForDirection(_ direction: DebtDirection) -> Color {
        switch direction {
        case .owedToMe: green
        case .iOwe: red
        }
    }
}
