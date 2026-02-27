import Foundation
import SwiftUI

extension Decimal {
    /// Formats with the user's chosen currency code (from AppStorage)
    func currencyFormatted(code: String? = nil) -> String {
        let currencyCode = code ?? UserDefaults.standard.string(forKey: "currencyCode") ?? "USD"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = Locale.current.groupingSeparator
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "0.00"
    }

    /// Formats with thousand separators but no currency symbol
    var thousandFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = Locale.current.groupingSeparator
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "0"
    }

    private var currencySymbol: String {
        let code = UserDefaults.standard.string(forKey: "currencyCode") ?? "USD"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.currencySymbol ?? "$"
    }
}
