import SwiftUI

private let S = AppStrings.shared

/// Consent toggle for AI insights. Reads/writes `AIConsent.isGranted` so the
/// Edge Function's `consent: true` precondition can be satisfied. When OFF
/// the dashboard's AI tap is a no-op — no data leaves the device.
struct AIInsightsSection: View {
    @Binding var consentGranted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionHeader(title: S.tr("ai.settings.title"), icon: "sparkles")
                .padding(.bottom, 12)

            SettingsCard {
                VStack(spacing: 0) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ColorTokens.primaryAccent.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: "sparkles")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(ColorTokens.primaryAccent)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(S.tr("ai.settings.consentToggle"))
                                .font(AppTypography.body)
                                .foregroundStyle(ColorTokens.textPrimary)
                            Text(S.tr("ai.settings.consentSubtitle"))
                                .font(AppTypography.caption)
                                .foregroundStyle(ColorTokens.textTertiary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()

                        Toggle("", isOn: $consentGranted)
                            .labelsHidden()
                            .tint(ColorTokens.primaryAccent)
                    }
                    .padding(14)

                    Divider().background(ColorTokens.surfaceBorder)

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(ColorTokens.gold)
                        Text(S.tr("ai.settings.howItWorksBody"))
                            .font(AppTypography.caption)
                            .foregroundStyle(ColorTokens.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                }
            }
        }
    }
}
