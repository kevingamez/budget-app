import SwiftUI

private let S = AppStrings.shared

struct DebtActionsSection: View {
    let canForgive: Bool
    let onForgive: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if canForgive {
                forgiveButton
            }
            deleteButton
        }
    }

    private var forgiveButton: some View {
        Button {
            withAnimation { onForgive() }
        } label: {
            HStack {
                Image(systemName: "hand.raised.fill")
                Text(S.tr("detail.forgiveDebt"))
            }
            .font(AppTypography.headline)
            .foregroundStyle(ColorTokens.gold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(ColorTokens.gold.opacity(0.15),
                        in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
        }
        .pressable()
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            HStack {
                Image(systemName: "trash.fill")
                Text(S.tr("detail.deleteDebt"))
            }
            .font(AppTypography.headline)
            .foregroundStyle(ColorTokens.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(ColorTokens.red.opacity(0.15),
                        in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
        }
        .pressable()
    }
}
