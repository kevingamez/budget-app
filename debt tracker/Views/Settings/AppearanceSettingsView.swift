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
    @State private var themeManager = ThemeManager.shared
    @State private var convertAmount: String = "100"
    @State private var convertTo: String = "COP"

    var body: some View {
        ZStack {
            ColorTokens.background.ignoresSafeArea()

            List {
                themeSection
                currencySection
                converterSection
                directionSection
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(S.tr("appearance.title"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task { await currencyService.fetchRates() }
    }

    // MARK: - Sections

    private var themeSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AppThemePalette.allPresets) { palette in
                        ThemePickerCard(
                            palette: palette,
                            isSelected: themeManager.currentId == palette.id
                        ) {
                            withAnimation(AppAnimations.cardSpring) {
                                themeManager.select(palette)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        } header: {
            Text(S.tr("appearance.theme"))
                .foregroundStyle(ColorTokens.textTertiary)
        }
        .listRowBackground(ColorTokens.surface)
    }

    private var currencySection: some View {
        Section {
            CurrencyPickerSection(
                currencies: Self.allCurrencies,
                currencyCode: $currencyCode,
                currencyService: currencyService
            )
        } header: {
            Text(S.tr("appearance.currency"))
                .foregroundStyle(ColorTokens.textTertiary)
        } footer: {
            if let lastFetched = currencyService.lastFetched {
                Text(S.tr("appearance.ratesUpdated", lastFetched.relativeFormatted))
                    .foregroundStyle(ColorTokens.textTertiary)
            }
        }
        .listRowBackground(ColorTokens.surface)
    }

    private var converterSection: some View {
        Section {
            CurrencyConverterSection(
                currencies: Self.allCurrencies,
                currencyCode: currencyCode,
                convertAmount: $convertAmount,
                convertTo: $convertTo,
                currencyService: currencyService
            )
        } header: {
            Text(S.tr("appearance.currencyConverter"))
                .foregroundStyle(ColorTokens.textTertiary)
        }
        .listRowBackground(ColorTokens.surface)
    }

    private var directionSection: some View {
        Section {
            DefaultDirectionSection(defaultDirection: $defaultDirection)
        } header: {
            Text(S.tr("appearance.defaultDirection"))
                .foregroundStyle(ColorTokens.textTertiary)
        }
        .listRowBackground(ColorTokens.surface)
    }
}
