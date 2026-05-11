import SwiftUI

private let S = AppStrings.shared

struct ActivityRowView: View {
    let payment: Payment
    let isLast: Bool

    @Environment(\.dynamicTypeSize) private var typeSize

    private var direction: DebtDirection {
        payment.debt?.direction ?? .owedToMe
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Timeline
            VStack(spacing: 0) {
                Circle()
                    .fill(ColorTokens.colorForDirection(direction))
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)

                if !isLast {
                    Rectangle()
                        .fill(ColorTokens.surfaceBorder)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 10)

            // Content
            contentLayout {
                PersonAvatarView(person: payment.debt?.person, size: .small)

                VStack(alignment: .leading, spacing: 4) {
                    Text(payment.debt?.personName ?? S.tr("common.unknown"))
                        .font(AppTypography.headline)
                        .foregroundStyle(ColorTokens.textPrimary)

                    Text(payment.debt?.title ?? "")
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.textTertiary)
                        .lineLimit(1)

                    if let notes = payment.notes {
                        Text(notes)
                            .font(AppTypography.caption)
                            .foregroundStyle(ColorTokens.textTertiary)
                            .italic()
                            .lineLimit(1)
                    }
                }

                if typeSize < .accessibility1 {
                    Spacer()
                }

                VStack(alignment: typeSize >= .accessibility1 ? .leading : .trailing, spacing: 4) {
                    Text(payment.amount.currencyFormatted)
                        .font(AppTypography.amountSmall)
                        .foregroundStyle(ColorTokens.colorForDirection(direction))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(payment.date.relativeFormatted)
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.textTertiary)
                }
            }
            .padding(.vertical, 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            S.tr(
                "a11y.payment.row",
                payment.amount.currencyFormatted,
                payment.debt?.personName ?? S.tr("common.unknown"),
                payment.date.relativeFormatted
            )
        )
    }

    /// At accessibility sizes the amount drops below the name+meta column.
    @ViewBuilder
    private func contentLayout<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if typeSize >= .accessibility1 {
            VStack(alignment: .leading, spacing: 8) { content() }
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack(spacing: 12) { content() }
        }
    }
}
