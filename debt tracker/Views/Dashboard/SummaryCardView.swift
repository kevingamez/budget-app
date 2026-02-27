import SwiftUI

struct SummaryCardView: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(gradient.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(gradient)
            }

            Text(value)
                .font(AppTypography.title2)
                .foregroundStyle(ColorTokens.textPrimary)
                .contentTransition(.numericText())

            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(ColorTokens.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .cardStyle()
    }
}
