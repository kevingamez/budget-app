import SwiftUI

enum AppTypography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title = Font.system(.title, design: .rounded).weight(.bold)
    static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
    static let title3 = Font.system(.title3, design: .rounded).weight(.semibold)
    static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let body = Font.system(.body, design: .rounded)
    static let callout = Font.system(.callout, design: .rounded)
    static let subheadline = Font.system(.subheadline, design: .rounded)
    static let footnote = Font.system(.footnote, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)
    /// Relative caption2 — scales with Dynamic Type. Prefer over fixed sub-11pt sizes.
    static let caption2 = Font.system(.caption2, design: .rounded)

    // Monospaced for currency amounts
    static let amountLarge = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let amount = Font.system(.title, design: .rounded).weight(.bold)
    static let amountSmall = Font.system(.title3, design: .rounded).weight(.semibold)
    static let amountMono = Font.system(.largeTitle, design: .monospaced).weight(.bold)
}
