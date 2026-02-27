import SwiftUI

private let S = AppStrings.shared

struct CurrencyInfo: Identifiable, Sendable {
    let id: String // currency code
    let symbol: String
    let name: String
}

struct AppearanceSettingsView: View {
    static let allCurrencies: [CurrencyInfo] = [
        CurrencyInfo(id: "USD", symbol: "$", name: "USD \u{2014} Dollar"),
        CurrencyInfo(id: "COP", symbol: "$", name: "COP \u{2014} Peso Colombiano"),
        CurrencyInfo(id: "EUR", symbol: "\u{20AC}", name: "EUR \u{2014} Euro"),
        CurrencyInfo(id: "GBP", symbol: "\u{00A3}", name: "GBP \u{2014} Pound"),
        CurrencyInfo(id: "MXN", symbol: "$", name: "MXN \u{2014} Peso Mexicano"),
        CurrencyInfo(id: "JPY", symbol: "\u{00A5}", name: "JPY \u{2014} Yen"),
        CurrencyInfo(id: "INR", symbol: "\u{20B9}", name: "INR \u{2014} Rupee"),
        CurrencyInfo(id: "KRW", symbol: "\u{20A9}", name: "KRW \u{2014} Won"),
        CurrencyInfo(id: "BRL", symbol: "R$", name: "BRL \u{2014} Real"),
    ]
    @AppStorage("currencyCode") private var currencyCode = "USD"
    @AppStorage("defaultDirection") private var defaultDirection = "owedToMe"
    @State private var currencyService = CurrencyService.shared
    @State private var convertAmount: String = "100"
    @State private var convertTo: String = "COP"

    var body: some View {
        ZStack {
            ColorTokens.background.ignoresSafeArea()

            List {
                // Currency Picker
                Section {
                    ForEach(Self.allCurrencies) { currency in
                        Button {
                            withAnimation(AppAnimations.cardSpring) {
                                currencyCode = currency.id
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Text(currency.symbol)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(ColorTokens.primaryAccent)
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(currency.name)
                                        .font(AppTypography.body)
                                        .foregroundStyle(ColorTokens.textPrimary)

                                    if let rate = currencyService.rate(from: "USD", to: currency.id), currency.id != "USD" {
                                        Text("1 USD = \(String(format: "%.2f", rate)) \(currency.id)")
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
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text(S.tr("appearance.currency"))
                        .foregroundStyle(ColorTokens.textTertiary)
                } footer: {
                    if let lastFetched = currencyService.lastFetched {
                        Text("Rates updated \(lastFetched.relativeFormatted)")
                            .foregroundStyle(ColorTokens.textTertiary)
                    }
                }
                .listRowBackground(ColorTokens.surface)

                // Live Converter
                Section {
                    VStack(spacing: 14) {
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

                        Image(systemName: "arrow.down")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(ColorTokens.textTertiary)

                        // Target currency picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Self.allCurrencies.filter { $0.id != currencyCode }) { currency in
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

                        // Result
                        if let amount = Decimal(string: convertAmount),
                           let converted = currencyService.convert(amount: amount, from: currencyCode, to: convertTo) {
                            HStack {
                                Text(formatConverted(converted, code: convertTo))
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
                    .padding(.vertical, 4)
                } header: {
                    Text(S.tr("appearance.currencyConverter"))
                        .foregroundStyle(ColorTokens.textTertiary)
                }
                .listRowBackground(ColorTokens.surface)

                // Default Direction
                Section {
                    Button {
                        withAnimation(AppAnimations.cardSpring) {
                            defaultDirection = "owedToMe"
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.down.left")
                                .foregroundStyle(ColorTokens.green)
                                .frame(width: 24)
                            Text(S.tr("direction.someoneOwesMe"))
                                .font(AppTypography.body)
                                .foregroundStyle(ColorTokens.textPrimary)
                            Spacer()
                            if defaultDirection == "owedToMe" {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(ColorTokens.green)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation(AppAnimations.cardSpring) {
                            defaultDirection = "iOwe"
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(ColorTokens.red)
                                .frame(width: 24)
                            Text(S.tr("direction.iOweSomeone"))
                                .font(AppTypography.body)
                                .foregroundStyle(ColorTokens.textPrimary)
                            Spacer()
                            if defaultDirection == "iOwe" {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(ColorTokens.red)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text(S.tr("appearance.defaultDirection"))
                        .foregroundStyle(ColorTokens.textTertiary)
                }
                .listRowBackground(ColorTokens.surface)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(S.tr("appearance.title"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await currencyService.fetchRates()
        }
    }

    private func formatConverted(_ value: Decimal, code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "0.00"
    }
}
