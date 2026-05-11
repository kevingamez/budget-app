import SwiftUI

private let S = AppStrings.shared

struct AboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionHeader(title: S.tr("settings.about"), icon: "info.circle.fill")
                .padding(.bottom, 12)

            SettingsCard {
                VStack(spacing: 0) {
                    aboutRow(title: S.tr("settings.version"), value: "1.0.0")
                    Divider().background(ColorTokens.surfaceBorder)
                    aboutRow(title: S.tr("settings.build"), value: "1")
                    Divider().background(ColorTokens.surfaceBorder)
                    aboutRow(title: S.tr("settings.developer"), value: "Kevin Gamez")
                    Divider().background(ColorTokens.surfaceBorder)
                    privacyRow
                }
            }
        }
        .padding(.bottom, 20)
    }

    private func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(ColorTokens.textPrimary)
            Spacer()
            Text(value)
                .font(AppTypography.body)
                .foregroundStyle(ColorTokens.textTertiary)
        }
        .padding(14)
    }

    private var privacyRow: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(ColorTokens.green.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ColorTokens.green)
            }

            Text(S.tr("settings.privacyNote"))
                .font(AppTypography.caption)
                .foregroundStyle(ColorTokens.textSecondary)
        }
        .padding(14)
    }
}
