import Testing
import Foundation
@testable import debt_tracker

@MainActor
@Suite("Currency formatting")
struct DecimalFormattingTests {
    @Test("currencyFormatted default produces a grouped, 2-decimal string with the locale currency symbol")
    func currencyFormattedDefault() {
        let value: Decimal = Decimal(string: "1234.56")!
        let formatted = value.currencyFormatted
        // Expect grouping + two decimals to be present somewhere in the formatted string.
        // The grouping/decimal separators depend on locale, but for USD/en the canonical
        // form is "$1,234.56".
        #expect(formatted.contains("1,234.56") || formatted.contains("1.234,56"))
        // The default currency code in the app is USD when nothing is set in UserDefaults.
        let usdSymbol = CurrencyFormatting.symbol(for: "USD")
        #expect(formatted.contains(usdSymbol))
    }

    @Test("currencyFormatted with an explicit code uses that currency")
    func currencyFormattedForCode() {
        let value: Decimal = Decimal(string: "10.00")!
        let eur = value.currencyFormatted(code: "EUR")
        let eurSymbol = CurrencyFormatting.symbol(for: "EUR")
        #expect(eur.contains(eurSymbol))
    }

    @Test("compactFormatted produces an M suffix for millions")
    func compactFormattedForMillions() {
        let value: Decimal = 1_500_000
        let compact = value.compactFormatted
        #expect(compact.contains("M"))
        #expect(compact.contains("1.5"))
    }

    @Test("compactFormatted produces a K suffix for thousands")
    func compactFormattedForThousands() {
        let value: Decimal = 12_500
        let compact = value.compactFormatted
        #expect(compact.contains("K"))
        #expect(compact.contains("12.5"))
    }

    // MARK: - Locale-aware amount parsing (comma-decimal regression guard)

    @Test("AmountInput parses comma-decimal input without 100x inflation")
    func amountInputCommaDecimal() {
        // German/Spanish-style "5,50" with ',' as the decimal separator → 5.50.
        #expect(AmountInput.parse("5,50", decimalSeparator: ",") == Decimal(string: "5.50"))
        // Grouped "1.234,56" ('.' grouping, ',' decimal) → 1234.56.
        #expect(AmountInput.parse("1.234,56", decimalSeparator: ",") == Decimal(string: "1234.56"))
    }

    @Test("AmountInput parses period-decimal input and strips grouping commas")
    func amountInputPeriodDecimal() {
        #expect(AmountInput.parse("5.50", decimalSeparator: ".") == Decimal(string: "5.50"))
        #expect(AmountInput.parse("1,234.56", decimalSeparator: ".") == Decimal(string: "1234.56"))
        // Plain integer input.
        #expect(AmountInput.parse("120", decimalSeparator: ".") == Decimal(120))
    }

    @Test("AmountInput returns nil for empty or non-numeric input")
    func amountInputInvalid() {
        #expect(AmountInput.parse("", decimalSeparator: ".") == nil)
        #expect(AmountInput.parse(",", decimalSeparator: ",") == nil)
        #expect(AmountInput.parse("abc", decimalSeparator: ".") == nil)
    }
}
