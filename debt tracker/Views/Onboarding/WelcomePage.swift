import SwiftUI

private let S = AppStrings.shared

struct WelcomePage: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Hero icon
            ZStack {
                Circle()
                    .fill(ColorTokens.primaryGradient)
                    .frame(width: 120, height: 120)
                    .shadow(color: ColorTokens.primaryAccent.opacity(0.4), radius: 20, y: 8)

                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.white)
            }
            .staggeredAppear(index: 0, appeared: appeared)

            VStack(spacing: 12) {
                Text(S.tr("welcome.welcomeTo"))
                    .font(AppTypography.title2)
                    .foregroundStyle(ColorTokens.textSecondary)

                Text(S.tr("welcome.appName"))
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(ColorTokens.textPrimary)
            }
            .staggeredAppear(index: 1, appeared: appeared)

            Text(S.tr("welcome.subtitle"))
                .font(AppTypography.body)
                .foregroundStyle(ColorTokens.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .staggeredAppear(index: 2, appeared: appeared)

            // Feature pills
            VStack(spacing: 10) {
                featurePill(icon: "chart.bar.fill", text: S.tr("welcome.dashboardAnalytics"))
                featurePill(icon: "bell.fill", text: S.tr("welcome.smartReminders"))
                featurePill(icon: "icloud.fill", text: S.tr("welcome.icloudSync"))
            }
            .staggeredAppear(index: 3, appeared: appeared)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
    }

    private func featurePill(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ColorTokens.primaryAccent)
                .frame(width: 20)

            Text(text)
                .font(AppTypography.subheadline)
                .foregroundStyle(ColorTokens.textPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(ColorTokens.surface, in: Capsule())
    }
}
