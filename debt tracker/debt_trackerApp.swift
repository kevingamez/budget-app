//
//  debt_trackerApp.swift
//  debt tracker
//
//  Created by Kevin Gamez on 2/27/26.
//

import SwiftUI
import SwiftData

extension Notification.Name {
    static let newDebtRequested = Notification.Name("newDebtRequested")
    static let requestTabSwitch = Notification.Name("requestTabSwitch")
}

@main
struct debt_trackerApp: App {
    let container: ModelContainer = Self.makeContainer()

    /// Build the SwiftData container with `.complete` file protection so the
    /// underlying SQLite is encrypted at rest (unreadable while the device is locked).
    private static func makeContainer() -> ModelContainer {
        let schema = Schema([Debt.self, Payment.self, Person.self, DebtCategory.self])
        let storeURL = URL.applicationSupportDirectory
            .appending(path: "DebtTracker.sqlite")
        let config = ModelConfiguration(schema: schema, url: storeURL)

        do {
            let container = try ModelContainer(for: schema, configurations: config)
            applyCompleteFileProtection(at: storeURL)
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    /// Apply `.complete` protection to the SwiftData SQLite + WAL/SHM siblings.
    private static func applyCompleteFileProtection(at storeURL: URL) {
        let fm = FileManager.default
        let candidates = [
            storeURL,
            storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal"),
            storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm"),
        ]
        for url in candidates where fm.fileExists(atPath: url.path) {
            try? fm.setAttributes(
                [.protectionKey: FileProtectionType.complete],
                ofItemAtPath: url.path
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    #if DEBUG
                    seedSampleDataIfNeeded()
                    #endif
                }
        }
        .modelContainer(container)
        #if os(macOS)
        .defaultSize(width: 1100, height: 750)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Debt") {
                    NotificationCenter.default.post(name: .newDebtRequested, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        #endif

        #if os(macOS)
        Settings {
            SettingsView()
                .modelContainer(container)
                .preferredColorScheme(ThemeManager.shared.current.preferredScheme)
        }
        #endif
    }

    #if DEBUG
    @MainActor
    private func seedSampleDataIfNeeded() {
        let key = "debugSampleDataSeeded"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        SampleDataService.seedSampleData(context: container.mainContext)
        do {
            try container.mainContext.save()
            UserDefaults.standard.set(true, forKey: key)
        } catch {
            print("Debug seed failed: \(error)")
        }
    }
    #endif
}
