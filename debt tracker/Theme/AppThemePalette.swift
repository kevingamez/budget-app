import SwiftUI

/// A complete color palette describing one selectable theme.
/// Gradients are derived from the flat accent colors so palettes
/// only need to specify the base hexes.
struct AppThemePalette: Identifiable, Hashable, Sendable {
    let id: String
    let nameKey: String          // AppStrings key, e.g. "theme.midnight"
    let preferredScheme: ColorScheme

    // Backgrounds
    let background: Color
    let surface: Color
    let surfaceElevated: Color
    let surfaceBorder: Color

    // Flat accents
    let primaryAccent: Color
    let primaryAccentSecondary: Color   // lighter sibling for gradients
    let green: Color
    let greenSecondary: Color
    let red: Color
    let redSecondary: Color
    let gold: Color
    let goldSecondary: Color
    let overdue: Color

    // Text
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color

    // Derived gradients
    var primaryGradient: LinearGradient {
        LinearGradient(colors: [primaryAccent, primaryAccentSecondary],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    var greenGradient: LinearGradient {
        LinearGradient(colors: [green, greenSecondary],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    var redGradient: LinearGradient {
        LinearGradient(colors: [red, redSecondary],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    var goldGradient: LinearGradient {
        LinearGradient(colors: [gold, goldSecondary],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension AppThemePalette {
    // MARK: - Presets

    static let midnightPurple = AppThemePalette(
        id: "midnight-purple",
        nameKey: "theme.midnight",
        preferredScheme: .dark,
        background: Color(hex: "#0A0A0F"),
        surface: Color(hex: "#1A1A2E"),
        surfaceElevated: Color(hex: "#222240"),
        surfaceBorder: Color(hex: "#2A2A4A"),
        primaryAccent: Color(hex: "#7C5CFC"),
        primaryAccentSecondary: Color(hex: "#A78BFA"),
        green: Color(hex: "#10B981"),
        greenSecondary: Color(hex: "#34D399"),
        red: Color(hex: "#EF4444"),
        redSecondary: Color(hex: "#F87171"),
        gold: Color(hex: "#F59E0B"),
        goldSecondary: Color(hex: "#FBBF24"),
        overdue: Color(hex: "#FF6B6B"),
        textPrimary: .white,
        textSecondary: Color.white.opacity(0.6),
        textTertiary: Color.white.opacity(0.55)
    )

    static let oceanDeep = AppThemePalette(
        id: "ocean-deep",
        nameKey: "theme.ocean",
        preferredScheme: .dark,
        background: Color(hex: "#06121C"),
        surface: Color(hex: "#0F2436"),
        surfaceElevated: Color(hex: "#173249"),
        surfaceBorder: Color(hex: "#1F4360"),
        primaryAccent: Color(hex: "#22D3EE"),
        primaryAccentSecondary: Color(hex: "#67E8F9"),
        green: Color(hex: "#14B8A6"),
        greenSecondary: Color(hex: "#2DD4BF"),
        red: Color(hex: "#F43F5E"),
        redSecondary: Color(hex: "#FB7185"),
        gold: Color(hex: "#FBBF24"),
        goldSecondary: Color(hex: "#FCD34D"),
        overdue: Color(hex: "#FF7A8A"),
        textPrimary: .white,
        textSecondary: Color.white.opacity(0.62),
        textTertiary: Color.white.opacity(0.55)
    )

    static let sunsetEmber = AppThemePalette(
        id: "sunset-ember",
        nameKey: "theme.sunset",
        preferredScheme: .dark,
        background: Color(hex: "#160B12"),
        surface: Color(hex: "#28131E"),
        surfaceElevated: Color(hex: "#3A1B2A"),
        surfaceBorder: Color(hex: "#4A2435"),
        primaryAccent: Color(hex: "#F97316"),
        primaryAccentSecondary: Color(hex: "#FB923C"),
        green: Color(hex: "#84CC16"),
        greenSecondary: Color(hex: "#A3E635"),
        red: Color(hex: "#E11D48"),
        redSecondary: Color(hex: "#F43F5E"),
        gold: Color(hex: "#EAB308"),
        goldSecondary: Color(hex: "#FACC15"),
        overdue: Color(hex: "#FF5577"),
        textPrimary: .white,
        textSecondary: Color.white.opacity(0.62),
        textTertiary: Color.white.opacity(0.55)
    )

    static let forestPine = AppThemePalette(
        id: "forest-pine",
        nameKey: "theme.forest",
        preferredScheme: .dark,
        background: Color(hex: "#08130E"),
        surface: Color(hex: "#11231B"),
        surfaceElevated: Color(hex: "#193228"),
        surfaceBorder: Color(hex: "#234334"),
        primaryAccent: Color(hex: "#22C55E"),
        primaryAccentSecondary: Color(hex: "#4ADE80"),
        green: Color(hex: "#16A34A"),
        greenSecondary: Color(hex: "#22C55E"),
        red: Color(hex: "#DC2626"),
        redSecondary: Color(hex: "#EF4444"),
        gold: Color(hex: "#CA8A04"),
        goldSecondary: Color(hex: "#EAB308"),
        overdue: Color(hex: "#F87171"),
        textPrimary: .white,
        textSecondary: Color.white.opacity(0.62),
        textTertiary: Color.white.opacity(0.55)
    )

    static let monoCarbon = AppThemePalette(
        id: "mono-carbon",
        nameKey: "theme.carbon",
        preferredScheme: .dark,
        background: Color(hex: "#0B0B0D"),
        surface: Color(hex: "#161618"),
        surfaceElevated: Color(hex: "#1F1F23"),
        surfaceBorder: Color(hex: "#2A2A30"),
        primaryAccent: Color(hex: "#E5E7EB"),
        primaryAccentSecondary: Color(hex: "#F3F4F6"),
        green: Color(hex: "#22C55E"),
        greenSecondary: Color(hex: "#4ADE80"),
        red: Color(hex: "#EF4444"),
        redSecondary: Color(hex: "#F87171"),
        gold: Color(hex: "#F59E0B"),
        goldSecondary: Color(hex: "#FBBF24"),
        overdue: Color(hex: "#FF6B6B"),
        textPrimary: .white,
        textSecondary: Color.white.opacity(0.62),
        textTertiary: Color.white.opacity(0.55)
    )

    static let porcelain = AppThemePalette(
        id: "porcelain",
        nameKey: "theme.porcelain",
        preferredScheme: .light,
        background: Color(hex: "#F6F5FB"),
        surface: Color(hex: "#FFFFFF"),
        surfaceElevated: Color(hex: "#F1EEFA"),
        surfaceBorder: Color(hex: "#E2DEEF"),
        primaryAccent: Color(hex: "#6D49F2"),
        primaryAccentSecondary: Color(hex: "#8B6BFB"),
        green: Color(hex: "#059669"),
        greenSecondary: Color(hex: "#10B981"),
        red: Color(hex: "#DC2626"),
        redSecondary: Color(hex: "#EF4444"),
        gold: Color(hex: "#D97706"),
        goldSecondary: Color(hex: "#F59E0B"),
        overdue: Color(hex: "#E11D48"),
        textPrimary: Color(hex: "#0F0B1F"),
        textSecondary: Color(hex: "#0F0B1F").opacity(0.65),
        textTertiary: Color(hex: "#0F0B1F").opacity(0.5)
    )

    static let allPresets: [AppThemePalette] = [
        .midnightPurple, .oceanDeep, .sunsetEmber, .forestPine, .monoCarbon, .porcelain,
    ]

    static func preset(id: String) -> AppThemePalette {
        allPresets.first(where: { $0.id == id }) ?? .midnightPurple
    }
}
