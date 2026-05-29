import Foundation
import SwiftUI

private enum CurrencyFormatterCache {
    private static var cache: [String: NumberFormatter] = [:]
    private static let lock = NSLock()

    static func formatter(for code: String, languageCode: String) -> NumberFormatter {
        let key = "\(code)|\(languageCode)"
        lock.lock(); defer { lock.unlock() }
        if let f = cache[key] { return f }
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = code
        f.locale = Locale(identifier: languageCode)
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        cache[key] = f
        return f
    }

    static func invalidate() {
        lock.lock(); cache.removeAll(); lock.unlock()
    }
}

private enum DecimalFormatterCache {
    private static var cache: [String: NumberFormatter] = [:]
    private static let lock = NSLock()

    /// Cached decimal (non-currency) formatter keyed by language + min/max fraction digits.
    static func formatter(languageCode: String, minFraction: Int, maxFraction: Int) -> NumberFormatter {
        let key = "\(languageCode)|\(minFraction)|\(maxFraction)"
        lock.lock(); defer { lock.unlock() }
        if let f = cache[key] { return f }
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: languageCode)
        f.minimumFractionDigits = minFraction
        f.maximumFractionDigits = maxFraction
        f.usesGroupingSeparator = true
        cache[key] = f
        return f
    }

    static func invalidate() {
        lock.lock(); cache.removeAll(); lock.unlock()
    }
}

/// Cross-file accessor so views (e.g. `AmountTextField`) can reuse the cached
/// formatter without spinning up a fresh `NumberFormatter` per keystroke.
enum CurrencyFormatting {
    static func symbol(for code: String) -> String {
        CurrencyFormatterCache.formatter(for: code, languageCode: AppStrings.shared.language).currencySymbol ?? "$"
    }

    /// Grouped decimal formatter respecting the active app language. Caller
    /// supplies fraction-digit policy; result is the shared cached formatter.
    static func decimalFormatter(minFraction: Int, maxFraction: Int) -> NumberFormatter {
        DecimalFormatterCache.formatter(languageCode: AppStrings.shared.language, minFraction: minFraction, maxFraction: maxFraction)
    }
}

/// Locale-aware parsing for user-entered monetary amounts.
///
/// The iOS `.decimalPad` shows whatever decimal key the *device* locale uses
/// (a comma across most of Europe and Latin America), while programmatic
/// round-trips (e.g. `NSDecimalNumber.stringValue`) always emit a period.
/// Calling `Decimal(string:)` directly drops the comma and silently inflates
/// the value ~100x ("5,50" → 550). `canonicalize` normalizes any such input to
/// a period-decimal, no-grouping string suitable for `Decimal(string:)`.
enum AmountInput {
    /// The decimal separator the on-screen keyboard / current device locale uses.
    static var localeDecimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }

    /// Normalizes the decimal mark to "." and strips grouping separators,
    /// currency symbols, and spaces. When the input contains the locale
    /// separator (e.g. ","), that is treated as the decimal mark and "." as a
    /// grouping separator; otherwise "." is the decimal mark. Only the first
    /// decimal mark is kept.
    static func canonicalize(_ input: String, decimalSeparator: String? = nil) -> String {
        let localeSep = decimalSeparator ?? localeDecimalSeparator
        let decimalMark: Character
        if localeSep != ".", localeSep.count == 1, input.contains(localeSep) {
            decimalMark = Character(localeSep)
        } else {
            decimalMark = "."
        }
        var result = ""
        var hasDecimal = false
        for char in input {
            if char.isNumber {
                result.append(char)
            } else if char == decimalMark && !hasDecimal {
                hasDecimal = true
                result.append(".")
            }
            // Everything else (grouping separators, symbols, spaces) is dropped.
        }
        return result
    }

    /// Parses user input into a `Decimal`, returning nil for empty/invalid input.
    static func parse(_ input: String, decimalSeparator: String? = nil) -> Decimal? {
        let canonical = canonicalize(input, decimalSeparator: decimalSeparator)
        guard !canonical.isEmpty, canonical != "." else { return nil }
        return Decimal(string: canonical)
    }
}

extension Decimal {
    /// Formats with the user's chosen currency code (from AppStorage)
    func currencyFormatted(code: String? = nil) -> String {
        let currencyCode = code ?? UserDefaults.standard.string(forKey: "currencyCode") ?? "USD"
        let language = AppStrings.shared.language
        let formatter = CurrencyFormatterCache.formatter(for: currencyCode, languageCode: language)
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "$0.00"
    }

    /// Short version: symbol + formatted number with thousand separators
    var currencyFormatted: String {
        currencyFormatted()
    }

    var compactFormatted: String {
        let symbol = currencySymbol
        let doubleValue = NSDecimalNumber(decimal: self).doubleValue
        let absValue = abs(doubleValue)
        let sign = doubleValue < 0 ? "-" : ""

        if absValue >= 1_000_000 {
            return "\(sign)\(symbol)\(String(format: "%.1fM", absValue / 1_000_000))"
        } else if absValue >= 1_000 {
            return "\(sign)\(symbol)\(String(format: "%.1fK", absValue / 1_000))"
        } else {
            return currencyFormatted
        }
    }

    var plainFormatted: String {
        let language = AppStrings.shared.language
        let formatter = DecimalFormatterCache.formatter(languageCode: language, minFraction: 2, maxFraction: 2)
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "0.00"
    }

    /// Formats with thousand separators but no currency symbol
    var thousandFormatted: String {
        let language = AppStrings.shared.language
        let formatter = DecimalFormatterCache.formatter(languageCode: language, minFraction: 0, maxFraction: 2)
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "0"
    }

    private var currencySymbol: String {
        let code = UserDefaults.standard.string(forKey: "currencyCode") ?? "USD"
        let language = AppStrings.shared.language
        let formatter = CurrencyFormatterCache.formatter(for: code, languageCode: language)
        return formatter.currencySymbol ?? "$"
    }
}
