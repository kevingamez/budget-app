import SwiftUI

private let S = AppStrings.shared

/// Compact two-up tile row — the small surface for headline numbers
/// (active debts, overdue, almost paid) like Revolut's analytics preview.
struct InsightTilesRow: View {
    let activeCount: Int
    let overdueCount: Int
    let almostPaidCount: Int

    var body: some View {
        HStack(spacing: 12) {
            InsightTile(
                value: "\(activeCount)",
                label: S.tr("dashboard.activeDebts"),
                icon: "doc.text.fill",
                tint: ColorTokens.primaryAccent
            )
            InsightTile(
                value: "\(overdueCount)",
                label: S.tr("dashboard.overdue"),
                icon: "exclamationmark.triangle.fill",
                tint: overdueCount > 0 ? ColorTokens.red : ColorTokens.green
            )
            InsightTile(
                value: "\(almostPaidCount)",
                label: S.tr("dashboard.almostPaid"),
                icon: "checkmark.seal.fill",
                tint: ColorTokens.gold
            )
        }
    }
}

private struct InsightTile: View {
    let value: String
    let label: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.15))
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(tint)
            }
            .frame(width: 28, height: 28)

            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(ColorTokens.textPrimary)
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(ColorTokens.textTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ColorTokens.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorTokens.surfaceBorder, lineWidth: 0.5)
                )
        )
    }
}
