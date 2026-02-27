import SwiftUI

enum AppTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)

    // Monospaced for currency amounts
    static let amountLarge = Font.system(size: 36, weight: .bold, design: .rounded)
    static let amount = Font.system(size: 28, weight: .bold, design: .rounded)
    static let amountSmall = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let amountMono = Font.system(size: 32, weight: .bold, design: .monospaced)
}
