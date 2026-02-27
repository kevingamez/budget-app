import SwiftUI

private let S = AppStrings.shared

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            ColorTokens.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Pages
                TabView(selection: $viewModel.currentPage) {
                    WelcomePage()
                        .tag(0)

                    LanguageSelectionPage(selectedLanguage: $viewModel.selectedLanguage)
                        .tag(1)

                    CurrencySelectionPage(selectedCurrencyCode: $viewModel.selectedCurrencyCode)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.currentPage)

                // Bottom controls
                VStack(spacing: 16) {
                    // Custom page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<viewModel.totalPages, id: \.self) { index in
                            Capsule()
                                .fill(index == viewModel.currentPage ? ColorTokens.primaryAccent : ColorTokens.surfaceBorder)
                                .frame(width: index == viewModel.currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentPage)
                        }
                    }

                    // Navigation buttons
                    HStack {
                        // Back button
                        if viewModel.currentPage > 0 {
                            Button {
                                withAnimation(AppAnimations.cardSpring) {
                                    viewModel.previousPage()
                                }
                            } label: {
                                Text(S.tr("common.back"))
                                    .font(AppTypography.body)
                                    .foregroundStyle(ColorTokens.textSecondary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                            }
                            .transition(.opacity)
                        }

                        Spacer()

                        // Next / Get Started
                        Button {
                            if viewModel.isLastPage {
                                viewModel.completeOnboarding()
                                withAnimation(AppAnimations.sheetSpring) {
                                    hasCompletedOnboarding = true
                                }
                            } else {
                                withAnimation(AppAnimations.cardSpring) {
                                    viewModel.nextPage()
                                }
                            }
                        } label: {
                            Text(viewModel.isLastPage ? S.tr("common.getStarted") : S.tr("common.next"))
                                .font(AppTypography.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 14)
                                .background(ColorTokens.primaryGradient, in: Capsule())
                        }
                        .pressable()
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
