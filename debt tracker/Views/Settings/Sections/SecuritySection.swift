import SwiftUI

private let S = AppStrings.shared

struct SecuritySection: View {
    @Binding var requireBiometrics: Bool
    let biometricsAvailable: Bool
    let biometricIcon: String
    let biometricLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionHeader(title: S.tr("settings.security"), icon: "lock.shield.fill")
                .padding(.bottom, 12)

            SettingsCard {
                VStack(spacing: 0) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ColorTokens.green.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: biometricIcon)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(ColorTokens.green)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(S.tr("settings.requireBiometric", biometricLabel))
                                .font(AppTypography.body)
                                .foregroundStyle(ColorTokens.textPrimary)
                            Text(S.tr("settings.lockOnLaunch"))
                                .font(AppTypography.caption)
                                .foregroundStyle(ColorTokens.textTertiary)
                        }

                        Spacer()

                        Toggle("", isOn: $requireBiometrics)
                            .labelsHidden()
                            .tint(ColorTokens.primaryAccent)
                            .disabled(!biometricsAvailable)
                    }
                    .padding(14)

                    if !biometricsAvailable {
                        Divider().background(ColorTokens.surfaceBorder)
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundStyle(ColorTokens.gold)
                            Text(S.tr("settings.biometricsUnavailable"))
                                .font(AppTypography.caption)
                                .foregroundStyle(ColorTokens.textTertiary)
                        }
                        .padding(14)
                    }
                }
            }
        }
    }
}
