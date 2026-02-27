import SwiftUI
import PhotosUI

private let S = AppStrings.shared

struct ProfileSettingsView: View {
    @State private var viewModel = ProfileViewModel()
    @AppStorage("preferredLanguage") private var preferredLanguage = "en"
    @AppStorage("currencyCode") private var currencyCode = "USD"

    var body: some View {
        ZStack {
            ColorTokens.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Profile Photo
                    photoSection

                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text(S.tr("profile.name"))
                            .font(AppTypography.footnote)
                            .foregroundStyle(ColorTokens.textSecondary)

                        TextField(S.tr("profile.namePlaceholder"), text: $viewModel.name)
                            .font(AppTypography.body)
                            .foregroundStyle(ColorTokens.textPrimary)
                            .padding(12)
                            .background(ColorTokens.surfaceElevated, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
                            .onChange(of: viewModel.name) { _, _ in
                                viewModel.saveName()
                            }
                    }

                    // Language
                    VStack(alignment: .leading, spacing: 8) {
                        Text(S.tr("profile.language"))
                            .font(AppTypography.footnote)
                            .foregroundStyle(ColorTokens.textSecondary)

                        NavigationLink {
                            languagePicker
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "globe")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(ColorTokens.primaryAccent)

                                Text(languageDisplayName)
                                    .font(AppTypography.body)
                                    .foregroundStyle(ColorTokens.textPrimary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(ColorTokens.textTertiary)
                            }
                            .padding(14)
                            .background(ColorTokens.surfaceElevated, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
                        }
                    }

                    // Currency
                    VStack(alignment: .leading, spacing: 8) {
                        Text(S.tr("profile.currency"))
                            .font(AppTypography.footnote)
                            .foregroundStyle(ColorTokens.textSecondary)

                        NavigationLink {
                            AppearanceSettingsView()
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "banknote.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(ColorTokens.green)

                                Text(currencyCode)
                                    .font(AppTypography.body)
                                    .foregroundStyle(ColorTokens.textPrimary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(ColorTokens.textTertiary)
                            }
                            .padding(14)
                            .background(ColorTokens.surfaceElevated, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
                        }
                    }
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.vertical, 20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(S.tr("profile.title"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            viewModel.loadExistingProfile()
        }
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        VStack(spacing: 14) {
            PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                ZStack {
                    if let data = viewModel.profileImageData {
                        #if canImport(UIKit)
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        }
                        #endif
                    } else {
                        Circle()
                            .fill(ColorTokens.primaryGradient)
                            .frame(width: 100, height: 100)

                        Text(viewModel.initials)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    // Camera badge
                    Circle()
                        .fill(ColorTokens.surfaceElevated)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(ColorTokens.primaryAccent)
                        )
                        .offset(x: 36, y: 36)
                }
            }
            .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
                if let newItem {
                    Task {
                        await viewModel.loadPhoto(from: newItem)
                    }
                }
            }

            if viewModel.isLoadingPhoto {
                ProgressView()
                    .tint(ColorTokens.primaryAccent)
            }

            if viewModel.hasPhoto {
                Button {
                    withAnimation(AppAnimations.cardSpring) {
                        viewModel.removePhoto()
                    }
                } label: {
                    Text(S.tr("profile.removePhoto"))
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.red)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Language Picker

    private var languagePicker: some View {
        ZStack {
            ColorTokens.background.ignoresSafeArea()

            List {
                ForEach(OnboardingViewModel.supportedLanguages) { language in
                    Button {
                        withAnimation(AppAnimations.cardSpring) {
                            preferredLanguage = language.id
                            AppStrings.shared.language = language.id
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Text(language.flag)
                                .font(.system(size: 24))

                            Text(language.name)
                                .font(AppTypography.body)
                                .foregroundStyle(ColorTokens.textPrimary)

                            Spacer()

                            if preferredLanguage == language.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(ColorTokens.primaryAccent)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(ColorTokens.surface)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(S.tr("profile.language"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: - Helpers

    private var languageDisplayName: String {
        OnboardingViewModel.supportedLanguages.first { $0.id == preferredLanguage }?.name ?? preferredLanguage
    }
}
