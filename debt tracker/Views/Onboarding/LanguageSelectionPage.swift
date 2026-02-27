import SwiftUI

private let S = AppStrings.shared

struct LanguageSelectionPage: View {
    @Binding var selectedLanguage: String
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 20)

            // Header
            VStack(spacing: 8) {
                Image(systemName: "globe")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(ColorTokens.primaryGradient)

                Text(S.tr("language.chooseLanguage"))
                    .font(AppTypography.title2)
                    .foregroundStyle(ColorTokens.textPrimary)

                Text(S.tr("language.subtitle"))
                    .font(AppTypography.caption)
                    .foregroundStyle(ColorTokens.textTertiary)
            }
            .staggeredAppear(index: 0, appeared: appeared)

            // Language list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(OnboardingViewModel.supportedLanguages.enumerated()), id: \.element.id) { index, language in
                        Button {
                            withAnimation(AppAnimations.cardSpring) {
                                selectedLanguage = language.id
                                AppStrings.shared.language = language.id
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Text(language.flag)
                                    .font(.system(size: 28))

                                Text(language.name)
                                    .font(AppTypography.body)
                                    .foregroundStyle(ColorTokens.textPrimary)

                                Spacer()

                                if selectedLanguage == language.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(ColorTokens.primaryAccent)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                selectedLanguage == language.id
                                    ? ColorTokens.primaryAccent.opacity(0.1)
                                    : Color.clear
                            )
                        }
                        .buttonStyle(.plain)

                        if index < OnboardingViewModel.supportedLanguages.count - 1 {
                            Divider()
                                .background(ColorTokens.surfaceBorder)
                                .padding(.leading, 58)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .fill(ColorTokens.surface)
                )
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .staggeredAppear(index: 1, appeared: appeared)

            Spacer()
        }
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
    }
}
