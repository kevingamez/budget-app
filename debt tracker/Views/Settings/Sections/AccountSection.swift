import SwiftUI

private let S = AppStrings.shared

struct AccountSection: View {
    let user: AuthUser?
    let onSignOutTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionHeader(title: S.tr("settings.account"), icon: "person.circle.fill")
                .padding(.bottom, 12)

            SettingsCard {
                VStack(spacing: 0) {
                    if let user {
                        userRow(user: user)
                        Divider().background(ColorTokens.surfaceBorder)
                    }
                    signOutButton
                }
            }
        }
    }

    private func userRow(user: AuthUser) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(ColorTokens.primaryAccent.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: providerIcon(user.provider))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ColorTokens.primaryAccent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(user.email ?? S.tr("settings.noEmail"))
                    .font(AppTypography.body)
                    .foregroundStyle(ColorTokens.textPrimary)
                Text(providerLabel(user.provider))
                    .font(AppTypography.caption)
                    .foregroundStyle(ColorTokens.textTertiary)
            }

            Spacer()
        }
        .padding(14)
    }

    private var signOutButton: some View {
        Button(action: onSignOutTapped) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ColorTokens.red.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(ColorTokens.red)
                }

                Text(S.tr("auth.signOut"))
                    .font(AppTypography.body)
                    .foregroundStyle(ColorTokens.red)

                Spacer()
            }
            .padding(14)
        }
    }

    private func providerIcon(_ provider: String) -> String {
        switch provider {
        case "apple": "apple.logo"
        case "google": "globe"
        default: "envelope.fill"
        }
    }

    private func providerLabel(_ provider: String) -> String {
        switch provider {
        case "apple": S.tr("auth.providerApple")
        case "google": S.tr("auth.providerGoogle")
        default: S.tr("auth.providerEmail")
        }
    }
}
