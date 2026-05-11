import Foundation

/// Centralized translation service for runtime language switching.
///
/// Translation entries live in per-topic files (`AppStrings+*.swift`).
/// `translations` merges them lazily on first access.
///
/// Usage: `let S = AppStrings.shared; Text(S.tr("key"))`
@Observable
final class AppStrings {
    static let shared = AppStrings()

    var language: String {
        didSet {
            UserDefaults.standard.set(language, forKey: "preferredLanguage")
        }
    }

    private init() {
        self.language = UserDefaults.standard.string(forKey: "preferredLanguage") ?? "en"
    }

    func tr(_ key: String) -> String {
        Self.translations[key]?[language]
            ?? Self.translations[key]?["en"]
            ?? key
    }

    /// Interpolated translation: replaces `%@` placeholders in order.
    func tr(_ key: String, _ args: String...) -> String {
        var result = tr(key)
        for arg in args {
            if let range = result.range(of: "%@") {
                result.replaceSubrange(range, with: arg)
            }
        }
        return result
    }

    /// Picks "<keyBase>.one" or "<keyBase>.other" based on count, then runs String(format:) with the count.
    func plural(_ keyBase: String, count: Int) -> String {
        let suffix = (count == 1) ? ".one" : ".other"
        return tr(keyBase + suffix, "\(count)")
    }

    // MARK: - Translation Dictionary

    /// Merged at first access from the per-topic dictionaries declared in the
    /// `AppStrings+*.swift` files. Add a new topic? Append it here.
    static let translations: [String: [String: String]] = {
        var merged: [String: [String: String]] = [:]
        let parts: [[String: [String: String]]] = [
            translationsTabsAndGreetings,
            translationsDashboard,
            translationsDebtsList,
            translationsDebtLabels,
            translationsCategories,
            translationsDebtDetail,
            translationsActivity,
            translationsSettings,
            translationsAlerts,
            translationsCommon,
            translationsProfile,
            translationsAppearance,
            translationsOnboarding,
            translationsExport,
            translationsAI,
            translationsAuth,
        ]
        for part in parts {
            merged.merge(part) { _, new in new }
        }
        return merged
    }()
}
