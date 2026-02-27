import SwiftUI
import SwiftData
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

private let S = AppStrings.shared

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var debts: [Debt]
    @Query private var payments: [Payment]
    @Query private var persons: [Person]
    @State private var viewModel = SettingsViewModel()
    @AppStorage("requireBiometrics") private var requireBiometrics = false
    @AppStorage("userName") private var userName = ""
    @State private var profilePhotoData: Data?
    @State private var showSignOutConfirmation = false
    private var authService = SupabaseAuthService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                ColorTokens.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        profileHeader

                        // Sections as cards
                        preferencesSection
                        securitySection
                        dataSection
                        accountSection
                        aboutSection
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(S.tr("settings.title"))
            .onAppear {
                viewModel.refreshStats(debts: debts, payments: payments, persons: persons)
                viewModel.checkBiometrics()
                profilePhotoData = ProfilePhotoStorage.load()
            }
            .onChange(of: debts.count) {
                viewModel.refreshStats(debts: debts, payments: payments, persons: persons)
            }
            .alert(S.tr("alert.loadSample.title"), isPresented: $viewModel.showSeedConfirmation) {
                Button(S.tr("common.cancel"), role: .cancel) {}
                Button(S.tr("alert.loadSample.action")) {
                    viewModel.seedSampleData(context: modelContext)
                    viewModel.refreshStats(debts: debts, payments: payments, persons: persons)
                }
            } message: {
                Text(S.tr("alert.loadSample.message"))
            }
            .alert(S.tr("alert.clearAll.title"), isPresented: $viewModel.showClearConfirmation) {
                Button(S.tr("common.cancel"), role: .cancel) {}
                Button(S.tr("alert.clearAll.action"), role: .destructive) {
                    viewModel.clearAllData(context: modelContext)
                    viewModel.refreshStats(debts: debts, payments: payments, persons: persons)
                }
            } message: {
                Text(S.tr("alert.clearAll.message"))
            }
            .alert(S.tr("alert.copied.title"), isPresented: $viewModel.showExportedAlert) {
                Button(S.tr("common.ok"), role: .cancel) {}
            } message: {
                Text(S.tr("alert.copied.message"))
            }
            .alert(S.tr("auth.signOutConfirm"), isPresented: $showSignOutConfirmation) {
                Button(S.tr("common.cancel"), role: .cancel) {}
                Button(S.tr("auth.signOut"), role: .destructive) {
                    Task { await authService.signOut() }
                }
            } message: {
                Text(S.tr("auth.signOutMessage"))
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        NavigationLink {
            ProfileSettingsView()
        } label: {
            VStack(spacing: 12) {
                // Profile photo or initials
                ZStack {
                    if let data = profilePhotoData {
                        #if canImport(UIKit)
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                        }
                        #endif
                    } else {
                        Circle()
                            .fill(ColorTokens.primaryGradient)
                            .frame(width: 70, height: 70)

                        Text(profileInitials)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }

                Text(userName.isEmpty ? S.tr("settings.setupProfile") : userName)
                    .font(AppTypography.title2)
                    .foregroundStyle(userName.isEmpty ? ColorTokens.textSecondary : ColorTokens.textPrimary)

                Text(userName.isEmpty ? S.tr("settings.tapToAddName") : S.tr("settings.tapToEditProfile"))
                    .font(AppTypography.caption)
                    .foregroundStyle(ColorTokens.textSecondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ColorTokens.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(ColorTokens.surface)
            )
        }
    }

    private var profileInitials: String {
        let trimmed = userName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "?" }
        let parts = trimmed.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(trimmed.prefix(2)).uppercased()
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: S.tr("settings.preferences"), icon: "gearshape.fill")
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                NavigationLink {
                    NotificationSettingsView()
                } label: {
                    settingsRow(icon: "bell.fill", iconColor: ColorTokens.red, title: S.tr("settings.notifications"))
                }

                Divider().background(ColorTokens.surfaceBorder)

                NavigationLink {
                    AppearanceSettingsView()
                } label: {
                    settingsRow(icon: "paintbrush.fill", iconColor: ColorTokens.primaryAccent, title: S.tr("settings.appearance"))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(ColorTokens.surface)
            )
        }
    }

    // MARK: - Security

    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: S.tr("settings.security"), icon: "lock.shield.fill")
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ColorTokens.green.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: viewModel.biometricIcon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(ColorTokens.green)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(S.tr("settings.requireBiometric", viewModel.biometricLabel))
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
                        .disabled(!viewModel.biometricsAvailable)
                }
                .padding(14)

                if !viewModel.biometricsAvailable {
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
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(ColorTokens.surface)
            )
        }
    }

    // MARK: - Data Management

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: S.tr("settings.data"), icon: "externaldrive.fill")
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                Button {
                    let summary = viewModel.exportSummary(debts: debts, payments: payments)
                    #if canImport(UIKit)
                    UIPasteboard.general.string = summary
                    #elseif canImport(AppKit)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(summary, forType: .string)
                    #endif
                    viewModel.showExportedAlert = true
                } label: {
                    settingsRow(icon: "doc.on.clipboard.fill", iconColor: ColorTokens.primaryAccent, title: S.tr("settings.exportSummary"))
                }

                Divider().background(ColorTokens.surfaceBorder)

                Button {
                    viewModel.showSeedConfirmation = true
                } label: {
                    settingsRow(icon: "tray.and.arrow.down.fill", iconColor: ColorTokens.gold, title: S.tr("settings.loadSample"))
                }

                Divider().background(ColorTokens.surfaceBorder)

                Button {
                    viewModel.showClearConfirmation = true
                } label: {
                    settingsRow(icon: "trash.fill", iconColor: ColorTokens.red, title: S.tr("settings.clearAll"))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(ColorTokens.surface)
            )
        }
    }

    // MARK: - Account

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: S.tr("settings.account"), icon: "person.circle.fill")
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                // User info
                if let user = authService.currentUser {
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

                    Divider().background(ColorTokens.surfaceBorder)
                }

                // Sign Out
                Button {
                    showSignOutConfirmation = true
                } label: {
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
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(ColorTokens.surface)
            )
        }
    }

    private func providerIcon(_ provider: String) -> String {
        switch provider {
        case "apple": return "apple.logo"
        case "google": return "globe"
        default: return "envelope.fill"
        }
    }

    private func providerLabel(_ provider: String) -> String {
        switch provider {
        case "apple": return S.tr("auth.providerApple")
        case "google": return S.tr("auth.providerGoogle")
        default: return S.tr("auth.providerEmail")
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: S.tr("settings.about"), icon: "info.circle.fill")
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                aboutRow(title: S.tr("settings.version"), value: "1.0.0")
                Divider().background(ColorTokens.surfaceBorder)
                aboutRow(title: S.tr("settings.build"), value: "1")
                Divider().background(ColorTokens.surfaceBorder)
                aboutRow(title: S.tr("settings.developer"), value: "Kevin Gamez")
                Divider().background(ColorTokens.surfaceBorder)

                // Privacy Note
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
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(ColorTokens.surface)
            )
        }
        .padding(.bottom, 20)
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ColorTokens.textTertiary)
            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(ColorTokens.textTertiary)
                .textCase(.uppercase)
        }
    }

    private func settingsRow(icon: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(ColorTokens.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ColorTokens.textTertiary)
        }
        .padding(14)
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
}
