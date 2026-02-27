import SwiftUI

private let S = AppStrings.shared

struct CurrencySelectionPage: View {
    @Binding var selectedCurrencyCode: String
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 20)

            // Header
            VStack(spacing: 8) {
                Image(systemName: "banknote.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(ColorTokens.greenGradient)

                Text(S.tr("currency.chooseCurrency"))
                    .font(AppTypography.title2)
                    .foregroundStyle(ColorTokens.textPrimary)

                Text(S.tr("currency.subtitle"))
                    .font(AppTypography.caption)
                    .foregroundStyle(ColorTokens.textTertiary)
            }
            .staggeredAppear(index: 0, appeared: appeared)

            // Currency list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(AppearanceSettingsView.allCurrencies.enumerated()), id: \.element.id) { index, currency in
                        Button {
                            withAnimation(AppAnimations.cardSpring) {
                                selectedCurrencyCode = currency.id
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Text(currency.symbol)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(ColorTokens.primaryAccent)
                                    .frame(width: 36)

                                Text(currency.name)
                                    .font(AppTypography.body)
                                    .foregroundStyle(ColorTokens.textPrimary)

                                Spacer()

                                if selectedCurrencyCode == currency.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(ColorTokens.primaryAccent)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                selectedCurrencyCode == currency.id
                                    ? ColorTokens.primaryAccent.opacity(0.1)
                                    : Color.clear
                            )
                        }
                        .buttonStyle(.plain)

                        if index < AppearanceSettingsView.allCurrencies.count - 1 {
                            Divider()
                                .background(ColorTokens.surfaceBorder)
                                .padding(.leading, 66)
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
