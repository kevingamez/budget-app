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

        // Set Application Support's protection class BEFORE the store is
        // created. Files inherit their parent directory's class on creation,
        // so this catches future WAL/SHM rolls and the SwiftData
        // `.externalStorage` blob directory that we don't enumerate by name.
        applyCompleteFileProtection(toDirectory: URL.applicationSupportDirectory)

        let config = ModelConfiguration(schema: schema, url: storeURL)

        do {
            let container = try ModelContainer(for: schema, configurations: config)
            // Belt-and-braces: tighten protection on every sibling that
            // already exists, since SwiftData may have created them before
            // we applied the directory class (first launch race) or with
            // SQLite's default `.completeUnlessOpen` class.
            applyCompleteFileProtection(toAllStoreSiblings: storeURL)
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

    /// Apply `.complete` protection to a directory so files created inside
    /// it later inherit the same class. iOS only applies inheritance at
    /// file-creation time, which is why we set this before the store opens.
    private static func applyCompleteFileProtection(toDirectory dir: URL) {
        let fm = FileManager.default
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true,
                                    attributes: [.protectionKey: FileProtectionType.complete])
            return
        }
        try? fm.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: dir.path
        )
    }

    /// Apply `.complete` to every file SwiftData might write next to the
    /// main store: the SQLite database, its WAL/SHM journals, and the
    /// `.externalStorage` blob folder used for `@Attribute(.externalStorage)`
    /// payloads (profile photos, etc.). Walks recursively so future
    /// per-attachment files inside the blob folder are covered too.
    private static func applyCompleteFileProtection(toAllStoreSiblings storeURL: URL) {
        let fm = FileManager.default
        let parent = storeURL.deletingLastPathComponent()
        let base = storeURL.deletingPathExtension().lastPathComponent

        let knownSiblings = [
            storeURL,
            parent.appending(path: "\(base).sqlite-wal"),
            parent.appending(path: "\(base).sqlite-shm"),
        ]
        for url in knownSiblings where fm.fileExists(atPath: url.path) {
            try? fm.setAttributes(
                [.protectionKey: FileProtectionType.complete],
                ofItemAtPath: url.path
            )
        }

        // SwiftData stores `.externalStorage` blobs in a folder named after
        // the store (e.g. `DebtTracker.sqlite_SUPPORT/external_data/...`).
        // Walk the parent directory and tighten anything whose name starts
        // with the store basename — covers both the SUPPORT folder and any
        // future variants Apple ships.
        if let entries = try? fm.contentsOfDirectory(at: parent, includingPropertiesForKeys: nil) {
            for entry in entries where entry.lastPathComponent.hasPrefix(base) {
                applyCompleteRecursive(at: entry)
            }
        }
    }

    private static func applyCompleteRecursive(at url: URL) {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: url.path, isDirectory: &isDir) else { return }

        try? fm.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: url.path
        )
        guard isDir.boolValue else { return }
        if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: nil) {
            for case let child as URL in enumerator {
                try? fm.setAttributes(
                    [.protectionKey: FileProtectionType.complete],
                    ofItemAtPath: child.path
                )
            }
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
