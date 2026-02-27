import SwiftUI

enum ColorTokens {
    // MARK: - Backgrounds
    static let background = Color(hex: "#0A0A0F")
    static let surface = Color(hex: "#1A1A2E")
    static let surfaceElevated = Color(hex: "#222240")
    static let surfaceBorder = Color(hex: "#2A2A4A")

    // MARK: - Accent Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "#7C5CFC"), Color(hex: "#A78BFA")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let greenGradient = LinearGradient(
        colors: [Color(hex: "#10B981"), Color(hex: "#34D399")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let redGradient = LinearGradient(
        colors: [Color(hex: "#EF4444"), Color(hex: "#F87171")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let goldGradient = LinearGradient(
        colors: [Color(hex: "#F59E0B"), Color(hex: "#FBBF24")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // MARK: - Flat Accents
    static let primaryAccent = Color(hex: "#7C5CFC")
    static let green = Color(hex: "#10B981")
    static let red = Color(hex: "#EF4444")
    static let gold = Color(hex: "#F59E0B")

    // MARK: - Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
    static let textTertiary = Color.white.opacity(0.35)

    // MARK: - Semantic
    static let owedToMeColor = green
    static let iOweColor = red
    static let overdueColor = Color(hex: "#FF6B6B")

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
