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
                // Theme Picker
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(AppThemePalette.allPresets) { palette in
                                ThemeCard(
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
                                    .font(.system(.headline, design: .rounded).weight(.bold))
                                    .foregroundStyle(ColorTokens.primaryAccent)
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(currency.name)
                                        .font(AppTypography.body)
                                        .foregroundStyle(ColorTokens.textPrimary)

                                    if let rate = currencyService.rate(from: "USD", to: currency.id), currency.id != "USD" {
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
                        .buttonStyle(.plain)
                    }
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
        let formatter = CurrencyFormatting.decimalFormatter(minFraction: 2, maxFraction: 2)
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "0.00"
    }
}

// MARK: - Theme Card

private struct ThemeCard: View {
    let palette: AppThemePalette
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                // Mini-preview canvas using the palette's own colors.
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(palette.background)

                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(palette.surface)
                            .frame(height: 18)
                            .overlay(alignment: .leading) {
                                HStack(spacing: 4) {
                                    Circle().fill(palette.primaryGradient).frame(width: 8, height: 8)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(palette.textSecondary)
                                        .frame(width: 36, height: 4)
                                }
                                .padding(.leading, 6)
                            }

                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(palette.greenGradient)
                                .frame(height: 22)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(palette.redGradient)
                                .frame(height: 22)
                        }

                        RoundedRectangle(cornerRadius: 6)
                            .fill(palette.surfaceElevated)
                            .frame(height: 14)
                    }
                    .padding(8)
                }
                .frame(width: 132, height: 84)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? palette.primaryAccent : Color.clear, lineWidth: 2)
                )

                HStack(spacing: 6) {
                    Text(AppStrings.shared.tr(palette.nameKey))
                        .font(AppTypography.caption)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundStyle(ColorTokens.textPrimary)
                        .lineLimit(1)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(ColorTokens.primaryAccent)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: 132, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppStrings.shared.tr(palette.nameKey))
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}
