import Foundation

/// Centralized clamps for user-supplied amounts and free-text fields. These
/// guard against `Decimal` overflow propagated from parser edge cases and
/// against pathological inputs (multi-megabyte notes, layout-DoS via huge
/// strings) sneaking into SwiftData.
enum InputBounds {
    /// Absolute ceiling on any amount the user can enter. A trillion is
    /// far past any real personal-finance use case but well below `Decimal`'s
    /// overflow boundary, so arithmetic stays exact.
    static let maxAmount = Decimal(string: "1000000000000") ?? Decimal.greatestFiniteMagnitude

    /// Title / person name length cap. Matches typical UITextField hints.
    static let titleMaxLength = 120

    /// Notes are bounded too — anything larger is almost certainly accidental
    /// paste and will only blow up layout / SwiftData payloads.
    static let notesMaxLength = 2000

    /// Clamp a parsed amount into the safe range. Returns 0 for NaN/negative
    /// values so callers can use the same `> 0` validity check as before.
    static func clamp(amount: Decimal) -> Decimal {
        if amount.isNaN { return 0 }
        if amount < 0 { return 0 }
        if amount > maxAmount { return maxAmount }
        return amount
    }

    /// Trim and length-cap a free-text field.
    static func bounded(_ string: String, max: Int) -> String {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= max { return trimmed }
        return String(trimmed.prefix(max))
    }
}
