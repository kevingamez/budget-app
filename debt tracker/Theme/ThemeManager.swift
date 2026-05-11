import Foundation
import SwiftUI

/// Central source of truth for the active visual theme.
/// Mutations are persisted to UserDefaults; views observe via @Observable.
@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    private static let storageKey = "selectedThemeId"

    var currentId: String {
        didSet {
            guard currentId != oldValue else { return }
            UserDefaults.standard.set(currentId, forKey: Self.storageKey)
        }
    }

    private init() {
        let stored = UserDefaults.standard.string(forKey: Self.storageKey) ?? AppThemePalette.midnightPurple.id
        self.currentId = stored
    }

    var current: AppThemePalette { AppThemePalette.preset(id: currentId) }

    func select(_ palette: AppThemePalette) {
        currentId = palette.id
    }
}
