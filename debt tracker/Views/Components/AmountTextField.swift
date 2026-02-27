import SwiftUI

private let S = AppStrings.shared

struct AmountTextField: View {
    @Binding var text: String
    var placeholder: String = "0.00"
    @AppStorage("currencyCode") private var currencyCode = "USD"
    @State private var showCurrencyPicker = false
    @FocusState private var isFocused: Bool
    @State private var cursorVisible = false

    private var currencySymbol: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.currencySymbol ?? "$"
    }

    /// Display text with thousand separators
    private var displayText: String {
        guard !text.isEmpty else { return "" }
        // Remove non-numeric chars except decimal point
        let cleaned = text.filter { $0.isNumber || $0 == "." }
        guard let number = Double(cleaned) else { return text }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = cleaned.contains(".") ? max(cleaned.split(separator: ".").last?.count ?? 0, 0) : 0
        formatter.usesGroupingSeparator = true

        return formatter.string(from: NSNumber(value: number)) ?? text
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(currencySymbol)
                    .font(AppTypography.title)
                    .foregroundStyle(isFocused ? ColorTokens.primaryAccent : ColorTokens.textTertiary)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)

                ZStack(alignment: .leading) {
                    // Placeholder
                    if text.isEmpty && !isFocused {
                        Text(placeholder)
                            .font(AppTypography.amountLarge)
                            .foregroundStyle(ColorTokens.textTertiary)
                    }

                    // Focused placeholder — subtler
                    if text.isEmpty && isFocused {
                        HStack(spacing: 0) {
                            Text(placeholder)
                                .font(AppTypography.amountLarge)
                                .foregroundStyle(ColorTokens.textTertiary.opacity(0.4))

                            // Blinking cursor
                            Rectangle()
                                .fill(ColorTokens.primaryAccent)
                                .frame(width: 2, height: 28)
                                .opacity(cursorVisible ? 1 : 0)
                        }
                    }

                    // Formatted display (visible)
                    if !text.isEmpty {
                        HStack(spacing: 0) {
                            Text(displayText)
                                .font(AppTypography.amountLarge)
                                .foregroundStyle(ColorTokens.textPrimary)
                                .contentTransition(.numericText())

                            // Blinking cursor after text
                            if isFocused {
                                Rectangle()
                                    .fill(ColorTokens.primaryAccent)
                                    .frame(width: 2, height: 28)
                                    .opacity(cursorVisible ? 1 : 0)
                                    .padding(.leading, 2)
                            }
                        }
                    }

                    // Invisible text field for input
                    TextField("", text: $text)
                        .font(AppTypography.amountLarge)
                        .foregroundStyle(.clear)
                        .tint(.clear)
                        .focused($isFocused)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .onChange(of: text) { _, newValue in
                            // Only allow numbers and one decimal point
                            let filtered = filterAmountInput(newValue)
                            if filtered != newValue {
                                text = filtered
                            }
                        }
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }

            // Currency badge — tappable to change currency
            HStack(spacing: 8) {
                Button {
                    showCurrencyPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Text(currencyCode)
                            .font(AppTypography.caption)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 8, weight: .bold))
                    }
                    .foregroundStyle(ColorTokens.primaryAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(ColorTokens.primaryAccent.opacity(0.15), in: Capsule())
                }
                .buttonStyle(.plain)

                if isFocused {
                    Text(S.tr("amount.tapToEnter"))
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.textTertiary)
                        .transition(.opacity)
                }

                Spacer()
            }

            // Underline — glows when focused
            Rectangle()
                .fill(isFocused ? ColorTokens.primaryAccent : ColorTokens.surfaceBorder)
                .frame(height: isFocused ? 2 : 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
        .sheet(isPresented: $showCurrencyPicker) {
            CurrencyPickerSheet(selectedCode: $currencyCode)
        }
        .onChange(of: isFocused) { _, focused in
            if focused {
                startCursorBlink()
            } else {
                cursorVisible = false
            }
        }
    }

    private func startCursorBlink() {
        cursorVisible = true
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            cursorVisible.toggle()
        }
    }

    var decimalValue: Decimal? {
        Decimal(string: text)
    }

    private func filterAmountInput(_ input: String) -> String {
        var result = ""
        var hasDecimal = false
        var decimalDigits = 0

        for char in input {
            if char.isNumber {
                if hasDecimal {
                    if decimalDigits < 2 {
                        result.append(char)
                        decimalDigits += 1
                    }
                } else {
                    result.append(char)
                }
            } else if char == "." && !hasDecimal {
                hasDecimal = true
                result.append(char)
            }
        }

        return result
    }
}

// MARK: - Currency Picker Sheet

private struct CurrencyPickerSheet: View {
    @Binding var selectedCode: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ColorTokens.background.ignoresSafeArea()

                List {
                    ForEach(AppearanceSettingsView.allCurrencies) { currency in
                        Button {
                            withAnimation(AppAnimations.cardSpring) {
                                selectedCode = currency.id
                            }
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Text(currency.symbol)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(ColorTokens.primaryAccent)
                                    .frame(width: 32)

                                Text(currency.name)
                                    .font(AppTypography.body)
                                    .foregroundStyle(ColorTokens.textPrimary)

                                Spacer()

                                if selectedCode == currency.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(ColorTokens.primaryAccent)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(ColorTokens.surface)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(S.tr("profile.currency"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(S.tr("common.done")) { dismiss() }
                        .foregroundStyle(ColorTokens.primaryAccent)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
