//
//  debt_trackerApp.swift
//  debt tracker
//
//  Created by Kevin Gamez on 2/27/26.
//

import SwiftUI
import SwiftData
import os

private let appLog = Logger(subsystem: "kevingamez.debt-tracker", category: "app")

extension Notification.Name {
    static let newDebtRequested = Notification.Name("newDebtRequested")
    static let requestTabSwitch = Notification.Name("requestTabSwitch")
}

@main
struct debt_trackerApp: App {
    /// The container is optional so a migration failure surfaces as a recovery
    /// screen instead of `fatalError`-crashing the app on first launch after
    /// a schema change.
    let container: ModelContainer? = Self.makeContainer()

    init() {
        #if DEBUG
        // UI-test launch: wipe defaults, fake auth, set known prefs *before*
        // ContentView's @AppStorage reads them. Sample data is seeded later,
        // when we have a live ModelContainer in hand.
        UITestSupport.resetUserDefaults()
        UITestSupport.fakeAuthenticate()
        #endif
    }

    private static func makeContainer() -> ModelContainer? {
        let schema = Schema([Debt.self, Payment.self, Person.self, DebtCategory.self])

        // UI tests get an in-memory store so each launch starts empty without
        // racing against on-disk SQLite cleanup. Production / DEBUG runs use
        // the real on-disk store with `.complete` file protection.
        #if DEBUG
        if UITestSupport.isActive {
            let memConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try? ModelContainer(for: schema, configurations: memConfig)
        }
        #endif

        let storeURL = URL.applicationSupportDirectory
            .appending(path: "DebtTracker.sqlite")
        let config = ModelConfiguration(schema: schema, url: storeURL)

        do {
            let container = try ModelContainer(for: schema, configurations: config)
            applyCompleteFileProtection(at: storeURL)
            return container
        } catch {
            // Migration failures are rare but real, and `fatalError` makes the
            // app un-launchable until the user reinstalls (losing all data).
            // Instead, log and return nil — the body shows a recovery screen
            // that lets the user wipe and retry without going through the App
            // Store reinstall dance.
            appLog.error("ModelContainer init failed: \(String(describing: error), privacy: .public)")
            return nil
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
            if let container {
                ContentView()
                    .modelContainer(container)
                    .task {
                        #if DEBUG
                        if UITestSupport.isActive {
                            UITestSupport.seedSampleData(container: container)
                        } else {
                            seedSampleDataIfNeeded(container: container)
                        }
                        #endif
                    }
            } else {
                StorageRecoveryView()
            }
        }
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
            if let container {
                SettingsView()
                    .modelContainer(container)
                    .preferredColorScheme(ThemeManager.shared.current.preferredScheme)
            } else {
                StorageRecoveryView()
            }
        }
        #endif
    }

    #if DEBUG
    @MainActor
    private func seedSampleDataIfNeeded(container: ModelContainer) {
        let key = "debugSampleDataSeeded"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        SampleDataService.seedSampleData(context: container.mainContext)
        do {
            try container.mainContext.save()
            UserDefaults.standard.set(true, forKey: key)
        } catch {
            appLog.error("Debug seed failed: \(String(describing: error), privacy: .public)")
        }
    }
    #endif
}

/// Shown when SwiftData fails to open the store (corrupted DB, failed migration).
/// Offers a destructive reset so the user can keep using the app instead of
/// being stuck on a launch crash.
private struct StorageRecoveryView: View {
    @State private var didReset = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)
            Text("Storage error")
                .font(.title2.weight(.semibold))
            Text("Your local database couldn't be opened. Resetting it will let the app launch again, but local debts will be lost.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            if didReset {
                Text("Reset complete — please reopen the app.")
                    .foregroundStyle(.secondary)
            } else {
                Button(role: .destructive) {
                    resetStore()
                    didReset = true
                } label: {
                    Text("Reset local data")
                        .frame(maxWidth: 240)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    private func resetStore() {
        let storeURL = URL.applicationSupportDirectory
            .appending(path: "DebtTracker.sqlite")
        let fm = FileManager.default
        let candidates = [
            storeURL,
            storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal"),
            storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm"),
        ]
        for url in candidates {
            try? fm.removeItem(at: url)
        }
    }
}
