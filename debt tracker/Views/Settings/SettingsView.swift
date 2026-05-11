import SwiftUI
import SwiftData

private let S = AppStrings.shared

/// Top-level Settings screen — composes the per-feature section views.
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
                        ProfileHeaderCard(userName: userName, profilePhotoData: profilePhotoData)
                        PreferencesSection()
                        SecuritySection(
                            requireBiometrics: $requireBiometrics,
                            biometricsAvailable: viewModel.biometricsAvailable,
                            biometricIcon: viewModel.biometricIcon,
                            biometricLabel: viewModel.biometricLabel
                        )
                        DataSection(
                            onExport: handleExport,
                            onLoadSample: { viewModel.showSeedConfirmation = true },
                            onClearAll: { viewModel.showClearConfirmation = true }
                        )
                        AccountSection(
                            user: authService.currentUser,
                            onSignOutTapped: { showSignOutConfirmation = true }
                        )
                        AboutSection()
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
            .modifier(SettingsAlerts(
                viewModel: viewModel,
                modelContext: modelContext,
                debts: debts,
                payments: payments,
                persons: persons,
                showSignOutConfirmation: $showSignOutConfirmation,
                authService: authService
            ))
        }
    }

    private func handleExport() {
        let summary = viewModel.exportSummary(debts: debts, payments: payments)
        ClipboardWriter.write(summary)
        viewModel.showExportedAlert = true
    }
}

/// Bundles the four confirmation alerts so the parent body stays terse.
private struct SettingsAlerts: ViewModifier {
    let viewModel: SettingsViewModel
    let modelContext: ModelContext
    let debts: [Debt]
    let payments: [Payment]
    let persons: [Person]
    @Binding var showSignOutConfirmation: Bool
    let authService: SupabaseAuthService

    func body(content: Content) -> some View {
        content
            .alert(S.tr("alert.loadSample.title"), isPresented: Binding(
                get: { viewModel.showSeedConfirmation },
                set: { viewModel.showSeedConfirmation = $0 }
            )) {
                Button(S.tr("common.cancel"), role: .cancel) {}
                Button(S.tr("alert.loadSample.action")) {
                    viewModel.seedSampleData(context: modelContext)
                    viewModel.refreshStats(debts: debts, payments: payments, persons: persons)
                }
            } message: {
                Text(S.tr("alert.loadSample.message"))
            }
            .alert(S.tr("alert.clearAll.title"), isPresented: Binding(
                get: { viewModel.showClearConfirmation },
                set: { viewModel.showClearConfirmation = $0 }
            )) {
                Button(S.tr("common.cancel"), role: .cancel) {}
                Button(S.tr("alert.clearAll.action"), role: .destructive) {
                    viewModel.clearAllData(context: modelContext)
                    viewModel.refreshStats(debts: debts, payments: payments, persons: persons)
                }
            } message: {
                Text(S.tr("alert.clearAll.message"))
            }
            .alert(S.tr("alert.copied.title"), isPresented: Binding(
                get: { viewModel.showExportedAlert },
                set: { viewModel.showExportedAlert = $0 }
            )) {
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
