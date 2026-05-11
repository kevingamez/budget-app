import SwiftUI

private let S = AppStrings.shared

struct CurrencyConverterSection: View {
    let currencies: [CurrencyInfo]
    let currencyCode: String
    @Binding var convertAmount: String
    @Binding var convertTo: String
    let currencyService: CurrencyService

    var body: some View {
        VStack(spacing: 14) {
            sourceRow
            Image(systemName: "arrow.down")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(ColorTokens.textTertiary)
            targetPicker
            result
        }
        .padding(.vertical, 4)
    }

    private var sourceRow: some View {
        HStack {
            TextField(S.tr("appearance.amountPlaceholder"), text: $convertAmount)
                .font(AppTypography.amountSmall)
                .foregroundStyle(ColorTokens.textPrimary)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif

            Text(currencyCode)
                .font(AppTypography.headline)
                .foregroundStyle(ColorTokens.primaryAccent)
        }
    }

    private var targetPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(currencies.filter { $0.id != currencyCode }) { currency in
                    Button {
                        convertTo = currency.id
                    } label: {
                        Text(currency.id)
                            .font(AppTypography.caption)
                            .fontWeight(convertTo == currency.id ? .bold : .regular)
                            .foregroundStyle(convertTo == currency.id ? .white : ColorTokens.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                convertTo == currency.id
                                    ? AnyShapeStyle(ColorTokens.primaryGradient)
                                    : AnyShapeStyle(ColorTokens.surfaceElevated),
                                in: Capsule()
                            )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var result: some View {
        if let amount = Decimal(string: convertAmount),
           let converted = currencyService.convert(amount: amount, from: currencyCode, to: convertTo) {
            HStack {
                Text(formatConverted(converted))
                    .font(AppTypography.amount)
                    .foregroundStyle(ColorTokens.green)
                    .contentTransition(.numericText())

                Text(convertTo)
                    .font(AppTypography.headline)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        } else if currencyService.isLoading {
            ProgressView()
                .tint(ColorTokens.primaryAccent)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        } else if currencyService.errorMessage != nil {
            Text(S.tr("appearance.ratesError"))
                .font(AppTypography.caption)
                .foregroundStyle(ColorTokens.red)
        }
    }

    private func formatConverted(_ value: Decimal) -> String {
        let formatter = CurrencyFormatting.decimalFormatter(minFraction: 2, maxFraction: 2)
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "0.00"
    }
}
