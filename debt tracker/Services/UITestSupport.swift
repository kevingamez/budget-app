#if DEBUG
import Foundation
import SwiftData

/// Helpers used **only** when the app is launched with the `-uitest-mode`
/// process argument from XCUITest. Bypasses auth + onboarding + biometrics
/// and seeds a clean batch of sample data so the test bundle can walk every
/// screen without needing real Supabase credentials.
///
/// This entire file is `#if DEBUG`, so it never ships in Release builds —
/// no bypass paths in production.
enum UITestSupport {
    static var isActive: Bool {
        ProcessInfo.processInfo.arguments.contains("-uitest-mode")
    }

    /// Wipe all user-scoped local state so each UI test run starts from a
    /// predictable baseline. Called before the SwiftData container is created
    /// so the seed-and-skip-onboarding flow lands on MainTabView directly.
    ///
    /// The SwiftData store itself is reset via an in-memory `ModelConfiguration`
    /// in `debt_trackerApp.makeContainer()` — that avoids the file-system race
    /// between deleting `.sqlite` and recreating it that broke the previous
    /// approach.
    static func resetUserDefaults() {
        guard isActive else { return }
        let keys = [
            "hasCompletedOnboarding",
            "requireBiometrics",
            "userName",
            "preferredLanguage",
            "currencyCode",
            "defaultDirection",
            "debugSampleDataSeeded",
            AIConsent.key,
            "ai_insights_daily_count",
            "ai_insights_daily_day",
        ]
        for key in keys { UserDefaults.standard.removeObject(forKey: key) }

        // Pre-set the values the tests expect.
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(false, forKey: "requireBiometrics")
        UserDefaults.standard.set("en", forKey: "preferredLanguage")
        UserDefaults.standard.set("USD", forKey: "currencyCode")
        UserDefaults.standard.set("Test User", forKey: "userName")
    }

    /// Inject a stub `AuthUser` into the singleton so `ContentView` treats the
    /// session as authenticated. The auth client itself is non-functional
    /// (no Secrets.plist), but `isAuthenticated` only checks `currentUser`.
    static func fakeAuthenticate() {
        guard isActive else { return }
        SupabaseAuthService.shared.currentUser = AuthUser(
            id: "00000000-0000-0000-0000-000000000001",
            email: "uitest@example.com",
            provider: "email"
        )
    }

    /// Force-reseed sample data inside the provided container so the test run
    /// is deterministic. The on-disk store is already wiped in `init`, so the
    /// container we receive here is empty and we just have to insert.
    @MainActor
    static func seedSampleData(container: ModelContainer) {
        guard isActive else { return }
        SampleDataService.seedSampleData(context: container.mainContext)
        try? container.mainContext.save()
    }

}
#endif
