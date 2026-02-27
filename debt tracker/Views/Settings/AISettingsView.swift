import SwiftUI

private let S = AppStrings.shared

struct AISettingsView: View {
    @State private var apiKeyInput: String = ""
    @State private var hasStoredKey: Bool = false
    @State private var showSavedAlert: Bool = false
    @State private var showDeleteConfirm: Bool = false

    var body: some View {
        ZStack {
            ColorTokens.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // API Key Section
                    VStack(alignment: .leading, spacing: 0) {
                        sectionHeader(S.tr("ai.settings.keyHeader"))
                            .padding(.bottom, 12)

                        VStack(spacing: 0) {
                            if hasStoredKey {
                                HStack(spacing: 14) {
                                    Image(systemName: "checkmark.shield.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(ColorTokens.green)
                                    Text(S.tr("ai.settings.keyStored"))
                                        .font(AppTypography.body)
                                        .foregroundStyle(ColorTokens.textPrimary)
                                    Spacer()
                                }
                                .padding(14)
                            } else {
                                SecureField(S.tr("ai.settings.placeholder"), text: $apiKeyInput)
                                    .font(AppTypography.body)
                                    .foregroundStyle(ColorTokens.textPrimary)
                                    .padding(14)

                                Divider().background(ColorTokens.surfaceBorder)

                                Button {
                                    guard !apiKeyInput.isEmpty else { return }
                                    if KeychainService.saveAPIKey(apiKeyInput) {
                                        apiKeyInput = ""
                                        hasStoredKey = true
                                        showSavedAlert = true
                                    }
                                } label: {
                                    Text(S.tr("ai.settings.save"))
                                        .font(AppTypography.headline)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                }
                                .disabled(apiKeyInput.isEmpty)
                                .opacity(apiKeyInput.isEmpty ? 0.5 : 1)
                                .padding(14)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                .fill(ColorTokens.surface)
                        )

                        Text(S.tr("ai.settings.keyFooter"))
                            .font(AppTypography.caption)
                            .foregroundStyle(ColorTokens.textTertiary)
                            .padding(.top, 8)
                            .padding(.horizontal, 4)
                    }

                    // Delete Key
                    if hasStoredKey {
                        Button {
                            showDeleteConfirm = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                Text(S.tr("ai.settings.deleteKey"))
                                    .font(AppTypography.body)
                            }
                            .foregroundStyle(ColorTokens.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(ColorTokens.surface)
                            )
                        }
                    }

                    // How It Works Section
                    VStack(alignment: .leading, spacing: 0) {
                        sectionHeader(S.tr("ai.settings.infoHeader"))
                            .padding(.bottom, 12)

                        VStack(alignment: .leading, spacing: 12) {
                            Text(S.tr("ai.settings.howItWorks"))
                                .font(AppTypography.headline)
                                .foregroundStyle(ColorTokens.textPrimary)

                            Text(S.tr("ai.settings.howItWorksBody"))
                                .font(AppTypography.subheadline)
                                .foregroundStyle(ColorTokens.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                .fill(ColorTokens.surface)
                        )
                    }
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(S.tr("ai.settings.title"))
        .onAppear {
            hasStoredKey = KeychainService.loadAPIKey() != nil
        }
        .alert(S.tr("ai.settings.saved.title"), isPresented: $showSavedAlert) {
            Button(S.tr("common.ok"), role: .cancel) {}
        } message: {
            Text(S.tr("ai.settings.saved.message"))
        }
        .alert(S.tr("ai.settings.deleteConfirm.title"), isPresented: $showDeleteConfirm) {
            Button(S.tr("common.cancel"), role: .cancel) {}
            Button(S.tr("ai.settings.deleteConfirm.action"), role: .destructive) {
                KeychainService.deleteAPIKey()
                hasStoredKey = false
            }
        } message: {
            Text(S.tr("ai.settings.deleteConfirm.message"))
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.footnote)
            .foregroundStyle(ColorTokens.textTertiary)
            .textCase(.uppercase)
    }
}
