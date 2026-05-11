import SwiftUI

private let S = AppStrings.shared

/// Revolut's signature: a giant number in a thin weight on flat background,
/// with the whole-units bold and the cents lighter to soften visual weight.
struct HeroBalanceView: View {
    let netBalance: Decimal
    let owedToMe: Decimal
    let iOwe: Decimal

    @Environment(\.dynamicTypeSize) private var typeSize

    private var sign: String { netBalance < 0 ? "-" : "" }
    private var absoluteString: String { abs(netBalance).currencyFormatted }

    /// Splits a formatted currency like "$1,234.56" into ("$1,234", ".56").
    private var split: (whole: String, fraction: String) {
        let str = absoluteString
        if let dotIdx = str.lastIndex(of: ".") {
            return (String(str[..<dotIdx]), String(str[dotIdx...]))
        }
        if let commaIdx = str.lastIndex(of: ",") {
            return (String(str[..<commaIdx]), String(str[commaIdx...]))
        }
        return (str, "")
    }

    var body: some View {
        VStack(alignment: .center, spacing: 14) {
            Text(S.tr("balance.netBalance").uppercased())
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(ColorTokens.textTertiary)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                if !sign.isEmpty {
                    Text(sign)
                        .font(.system(size: 56, weight: .light, design: .rounded))
                        .foregroundStyle(ColorTokens.textPrimary)
                }
                Text(split.whole)
                    .font(.system(size: 56, weight: .light, design: .rounded))
                    .foregroundStyle(ColorTokens.textPrimary)
                Text(split.fraction)
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .foregroundStyle(ColorTokens.textSecondary)
                    .baselineOffset(0)
            }
            .contentTransition(.numericText())
            .lineLimit(1)
            .minimumScaleFactor(0.6)

            chipsLayout {
                BalanceChip(
                    icon: "arrow.down.left",
                    label: S.tr("balance.owedToMe"),
                    amount: owedToMe,
                    tint: ColorTokens.green
                )
                BalanceChip(
                    icon: "arrow.up.right",
                    label: S.tr("balance.iOwe"),
                    amount: iOwe,
                    tint: ColorTokens.red
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    @ViewBuilder
    private func chipsLayout<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if typeSize >= .accessibility1 {
            VStack(spacing: 8) { content() }
        } else {
            HStack(spacing: 8) { content() }
        }
    }
}

private struct BalanceChip: View {
    let icon: String
    let label: String
    let amount: Decimal
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(tint)
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(ColorTokens.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(amount.currencyFormatted)
                .font(AppTypography.caption)
                .fontWeight(.semibold)
                .foregroundStyle(ColorTokens.textPrimary)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(ColorTokens.surface, in: Capsule())
        .overlay(Capsule().stroke(ColorTokens.surfaceBorder, lineWidth: 0.5))
    }
}
