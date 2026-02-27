import SwiftUI
import UserNotifications

private let S = AppStrings.shared

struct NotificationSettingsView: View {
    @State private var notificationsEnabled = false
    @State private var checkedStatus = false

    var body: some View {
        ZStack {
            ColorTokens.background.ignoresSafeArea()

            List {
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(S.tr("notifications.enable"))
                                .font(AppTypography.body)
                                .foregroundStyle(ColorTokens.textPrimary)

                            Text(S.tr("notifications.description"))
                                .font(AppTypography.caption)
                                .foregroundStyle(ColorTokens.textTertiary)
                        }
                    }
                    .tint(ColorTokens.primaryAccent)
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if newValue {
                            Task {
                                let granted = await NotificationService.shared.requestPermission()
                                if !granted {
                                    notificationsEnabled = false
                                }
                            }
                        }
                    }
                } header: {
                    Text(S.tr("notifications.sectionHeader"))
                        .foregroundStyle(ColorTokens.textTertiary)
                }
                .listRowBackground(ColorTokens.surface)

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(S.tr("notifications.howItWorks"))
                            .font(AppTypography.headline)
                            .foregroundStyle(ColorTokens.textPrimary)

                        Text(S.tr("notifications.howItWorksDescription"))
                            .font(AppTypography.subheadline)
                            .foregroundStyle(ColorTokens.textSecondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(S.tr("notifications.infoHeader"))
                        .foregroundStyle(ColorTokens.textTertiary)
                }
                .listRowBackground(ColorTokens.surface)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(S.tr("notifications.title"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            let status = await NotificationService.shared.checkPermissionStatus()
            notificationsEnabled = status == .authorized
            checkedStatus = true
        }
    }
}
