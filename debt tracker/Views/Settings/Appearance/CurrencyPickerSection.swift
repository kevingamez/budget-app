import SwiftUI

private let S = AppStrings.shared

struct CurrencyPickerSection: View {
    let currencies: [CurrencyInfo]
    @Binding var currencyCode: String
    let currencyService: CurrencyService

    var body: some View {
        ForEach(currencies) { currency in
            Button {
                withAnimation(AppAnimations.cardSpring) {
                    currencyCode = currency.id
                }
            } label: {
                row(for: currency)
            }
            .buttonStyle(.plain)
        }
    }

    private func row(for currency: CurrencyInfo) -> some View {
        HStack(spacing: 12) {
            Text(currency.symbol)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(ColorTokens.primaryAccent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(currency.name)
                    .font(AppTypography.body)
                    .foregroundStyle(ColorTokens.textPrimary)

                if currency.id != "USD",
                   let rate = currencyService.rate(from: "USD", to: currency.id) {
                    Text(S.tr("appearance.rate.format", String(format: "%.2f", rate), currency.id))
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.textTertiary)
                }
            }

            Spacer()

            if currencyCode == currency.id {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(ColorTokens.primaryAccent)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
