import SwiftUI
import AuthenticationServices

private let S = AppStrings.shared

struct AuthView: View {
    @State private var viewModel = AuthViewModel()

    var body: some View {
        ZStack {
            ColorTokens.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)

                    // Logo
                    ZStack {
                        Circle()
                            .fill(ColorTokens.primaryGradient)
                            .frame(width: 80, height: 80)
                            .shadow(color: ColorTokens.primaryAccent.opacity(0.4), radius: 16, y: 6)

                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .staggeredAppear(index: 0)

                    // Title
                    VStack(spacing: 6) {
                        Text(viewModel.isSignUp ? S.tr("auth.createAccount") : S.tr("auth.welcome"))
                            .font(AppTypography.title)
                            .foregroundStyle(ColorTokens.textPrimary)

                        Text(S.tr("auth.subtitle"))
                            .font(AppTypography.subheadline)
                            .foregroundStyle(ColorTokens.textSecondary)
                    }
                    .staggeredAppear(index: 1)

                    // Email & Password
                    VStack(spacing: 14) {
                        TextField(S.tr("auth.email"), text: $viewModel.email)
                            .textContentType(.emailAddress)
                            #if os(iOS)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            #endif
                            .autocorrectionDisabled()
                            .font(AppTypography.body)
                            .foregroundStyle(ColorTokens.textPrimary)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(ColorTokens.surface)
                            )

                        SecureField(S.tr("auth.password"), text: $viewModel.password)
                            .textContentType(viewModel.isSignUp ? .newPassword : .password)
                            .font(AppTypography.body)
                            .foregroundStyle(ColorTokens.textPrimary)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(ColorTokens.surface)
                            )

                        // Sign In / Sign Up Button
                        Button {
                            Task { await viewModel.signInWithEmail() }
                        } label: {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(viewModel.isSignUp ? S.tr("auth.signUp") : S.tr("auth.signIn"))
                                        .font(AppTypography.headline)
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(viewModel.isFormValid ? ColorTokens.primaryAccent : ColorTokens.primaryAccent.opacity(0.4))
                            )
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .staggeredAppear(index: 2)

                    // Error
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(AppTypography.caption)
                            .foregroundStyle(ColorTokens.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.screenPadding)
                    }

                    // Toggle Sign In / Sign Up
                    Button {
                        withAnimation(AppAnimations.cardSpring) {
                            viewModel.isSignUp.toggle()
                            viewModel.errorMessage = nil
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.isSignUp ? S.tr("auth.haveAccount") : S.tr("auth.noAccount"))
                                .foregroundStyle(ColorTokens.textSecondary)
                            Text(viewModel.isSignUp ? S.tr("auth.signIn") : S.tr("auth.signUp"))
                                .foregroundStyle(ColorTokens.primaryAccent)
                                .fontWeight(.semibold)
                        }
                        .font(AppTypography.subheadline)
                    }

                    // Divider
                    HStack {
                        Rectangle().fill(ColorTokens.surfaceBorder).frame(height: 1)
                        Text(S.tr("auth.orContinueWith"))
                            .font(AppTypography.caption)
                            .foregroundStyle(ColorTokens.textTertiary)
                        Rectangle().fill(ColorTokens.surfaceBorder).frame(height: 1)
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .staggeredAppear(index: 3)

                    // Social Buttons
                    VStack(spacing: 12) {
                        // Apple Sign In — native button is the actual tap target.
                        SignInWithAppleButton(.signIn,
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                                request.nonce = AppleSignInService.shared.currentNonceHash()
                            },
                            onCompletion: { result in
                                let raw = AppleSignInService.shared.currentRawNonce()
                                switch result {
                                case .success(let auth):
                                    guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                                          let tokenData = credential.identityToken,
                                          let idToken = String(data: tokenData, encoding: .utf8)
                                    else {
                                        viewModel.errorMessage = S.tr("ai.insights.error.title")
                                        return
                                    }
                                    Task { @MainActor in
                                        viewModel.isLoading = true
                                        await SupabaseAuthService.shared.signInWithIdToken(
                                            idToken: idToken,
                                            nonce: raw,
                                            provider: "apple"
                                        )
                                        if let error = SupabaseAuthService.shared.errorMessage {
                                            viewModel.errorMessage = error
                                        }
                                        viewModel.isLoading = false
                                    }
                                case .failure(let error):
                                    if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                                        viewModel.errorMessage = error.localizedDescription
                                    }
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(AppTheme.smallCornerRadius)

                        // Google Sign In (custom button)
                        Button {
                            // Google sign in requires more setup (OAuth client ID)
                            viewModel.errorMessage = S.tr("auth.googleNotConfigured")
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "globe")
                                    .font(.system(size: 18, weight: .semibold))
                                Text(S.tr("auth.signInGoogle"))
                                    .font(AppTypography.headline)
                            }
                            .foregroundStyle(ColorTokens.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(ColorTokens.surface)
                            )
                        }
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .staggeredAppear(index: 4)

                    Spacer().frame(height: 40)
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
