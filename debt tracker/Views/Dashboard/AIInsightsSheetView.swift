import SwiftUI

private let S = AppStrings.shared

struct InsightRequest: Identifiable {
    let id = UUID()
    let snapshot: FinancialSnapshot
    let gradient: LinearGradient
}

struct AIInsightsSheetView: View {
    let snapshot: FinancialSnapshot
    let cardGradient: LinearGradient
    @State private var viewModel = AIInsightsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            ColorTokens.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Capsule()
                    .fill(ColorTokens.textTertiary)
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(cardGradient)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(S.tr("ai.insights.title"))
                                    .font(AppTypography.title3)
                                    .foregroundStyle(ColorTokens.textPrimary)
                                Text(snapshot.tappedCardTitle)
                                    .font(AppTypography.caption)
                                    .foregroundStyle(ColorTokens.textSecondary)
                            }
                            Spacer()
                        }

                        Divider()
                            .background(ColorTokens.surfaceBorder)

                        // Content
                        if viewModel.isLoading {
                            loadingView
                        } else if viewModel.showNoAPIKeyPrompt {
                            noAPIKeyView
                        } else if let error = viewModel.errorMessage {
                            errorView(message: error)
                        } else if !viewModel.insightText.isEmpty {
                            insightView
                        }
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.bottom, 32)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .task {
            await viewModel.loadInsight(for: snapshot)
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(ColorTokens.primaryAccent)
            Text(S.tr("ai.insights.loading"))
                .font(AppTypography.subheadline)
                .foregroundStyle(ColorTokens.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    // MARK: - Insight Result

    private var insightView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.insightText)
                .font(AppTypography.body)
                .foregroundStyle(ColorTokens.textPrimary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                viewModel.clearCache()
                Task { await viewModel.loadInsight(for: snapshot) }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .semibold))
                    Text(S.tr("ai.insights.regenerate"))
                        .font(AppTypography.footnote)
                }
                .foregroundStyle(ColorTokens.primaryAccent)
                .padding(.top, 4)
            }
            .pressable()

            Text(S.tr("ai.insights.poweredBy"))
                .font(AppTypography.caption)
                .foregroundStyle(ColorTokens.textTertiary)
        }
    }

    // MARK: - No API Key

    private var noAPIKeyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "key.fill")
                .font(.system(size: 40))
                .foregroundStyle(ColorTokens.primaryGradient)

            Text(S.tr("ai.insights.noKey.title"))
                .font(AppTypography.title3)
                .foregroundStyle(ColorTokens.textPrimary)

            Text(S.tr("ai.insights.noKey.subtitle"))
                .font(AppTypography.subheadline)
                .foregroundStyle(ColorTokens.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .padding(.horizontal, 8)
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(ColorTokens.redGradient)

            Text(S.tr("ai.insights.error.title"))
                .font(AppTypography.title3)
                .foregroundStyle(ColorTokens.textPrimary)

            Text(message)
                .font(AppTypography.subheadline)
                .foregroundStyle(ColorTokens.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel.loadInsight(for: snapshot) }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .semibold))
                    Text(S.tr("ai.insights.error.retry"))
                        .font(AppTypography.subheadline)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(ColorTokens.primaryAccent, in: Capsule())
            }
            .pressable()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .padding(.horizontal, 8)
    }
}
