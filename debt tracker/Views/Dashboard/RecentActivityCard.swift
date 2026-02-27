import SwiftUI

private let S = AppStrings.shared

struct RecentActivityCard: View {
    let payments: [Payment]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ColorTokens.green)
                Text(S.tr("recent.title"))
                    .font(AppTypography.headline)
                    .foregroundStyle(ColorTokens.textPrimary)
                Spacer()
            }

            if payments.isEmpty {
                Text(S.tr("recent.empty"))
                    .font(AppTypography.subheadline)
                    .foregroundStyle(ColorTokens.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
            } else {
                ForEach(payments) { payment in
                    HStack(spacing: 12) {
                        PersonAvatarView(person: payment.debt?.person, size: .small)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(payment.debt?.personName ?? S.tr("common.unknown"))
                                .font(AppTypography.subheadline)
                                .foregroundStyle(ColorTokens.textPrimary)

                            Text(payment.debt?.title ?? "")
                                .font(AppTypography.caption)
                                .foregroundStyle(ColorTokens.textTertiary)
                                .lineLimit(1)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(payment.amount.currencyFormatted)
                                .font(AppTypography.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(ColorTokens.green)

                            Text(payment.date.relativeFormatted)
                                .font(AppTypography.caption)
                                .foregroundStyle(ColorTokens.textTertiary)
                        }
                    }

                    if payment.id != payments.last?.id {
                        Divider()
                            .background(ColorTokens.surfaceBorder)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
