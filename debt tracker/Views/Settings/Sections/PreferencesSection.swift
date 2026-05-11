import SwiftUI

private let S = AppStrings.shared

struct PreferencesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSectionHeader(title: S.tr("settings.preferences"), icon: "gearshape.fill")
                .padding(.bottom, 12)

            SettingsCard {
                VStack(spacing: 0) {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        SettingsRow(
                            icon: "bell.fill",
                            iconColor: ColorTokens.red,
                            title: S.tr("settings.notifications")
                        )
                    }

                    Divider().background(ColorTokens.surfaceBorder)

                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        SettingsRow(
                            icon: "paintbrush.fill",
                            iconColor: ColorTokens.primaryAccent,
                            title: S.tr("settings.appearance")
                        )
                    }
                }
            }
        }
    }
}
