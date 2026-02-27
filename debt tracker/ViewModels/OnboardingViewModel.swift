import Foundation

struct LanguageOption: Identifiable, Sendable {
    let id: String // language code
    let name: String // native name
    let flag: String // emoji flag
}

@Observable
final class OnboardingViewModel {
    static let supportedLanguages: [LanguageOption] = [
        LanguageOption(id: "en", name: "English", flag: "\u{1F1FA}\u{1F1F8}"),
        LanguageOption(id: "es", name: "Espanol", flag: "\u{1F1EA}\u{1F1F8}"),
        LanguageOption(id: "fr", name: "Francais", flag: "\u{1F1EB}\u{1F1F7}"),
        LanguageOption(id: "pt", name: "Portugues", flag: "\u{1F1E7}\u{1F1F7}"),
        LanguageOption(id: "ja", name: "日本語", flag: "\u{1F1EF}\u{1F1F5}"),
        LanguageOption(id: "ko", name: "한국어", flag: "\u{1F1F0}\u{1F1F7}"),
    ]

    var currentPage: Int = 0
    let totalPages: Int = 3

    var selectedLanguage: String = "en"
    var selectedCurrencyCode: String = "USD"

    var isLastPage: Bool { currentPage == totalPages - 1 }

    func nextPage() {
        if currentPage < totalPages - 1 {
            currentPage += 1
        }
    }

    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }

    func completeOnboarding() {
        UserDefaults.standard.set(selectedLanguage, forKey: "preferredLanguage")
        UserDefaults.standard.set(selectedCurrencyCode, forKey: "currencyCode")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        AppStrings.shared.language = selectedLanguage
    }
}
