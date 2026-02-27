//
//  debt_trackerApp.swift
//  debt tracker
//
//  Created by Kevin Gamez on 2/27/26.
//

import SwiftUI
import SwiftData

@main
struct debt_trackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [
            Debt.self,
            Payment.self,
            Person.self,
            DebtCategory.self,
        ])
    }

    init() {
        #if DEBUG
        seedSampleDataIfNeeded()
        loadAPIKeyFromEnv()
        #endif
    }

    #if DEBUG
    private func seedSampleDataIfNeeded() {
        let key = "debugSampleDataSeeded"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        Task { @MainActor in
            do {
                let container = try ModelContainer(for: Debt.self, Payment.self, Person.self, DebtCategory.self)
                SampleDataService.seedSampleData(context: container.mainContext)
                try container.mainContext.save()
                UserDefaults.standard.set(true, forKey: key)
            } catch {
                print("Debug seed failed: \(error)")
            }
        }
    }

    private func loadAPIKeyFromEnv() {
        // Skip if key already in Keychain
        if KeychainService.loadAPIKey() != nil { return }

        // Walk up from the app bundle to find .env at the project root
        var dir = Bundle.main.bundleURL.deletingLastPathComponent()
        for _ in 0..<10 {
            let envFile = dir.appendingPathComponent(".env")
            if let contents = try? String(contentsOf: envFile, encoding: .utf8) {
                for line in contents.components(separatedBy: .newlines) {
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasPrefix("ANTHROPIC_API_KEY=") {
                        let value = String(trimmed.dropFirst("ANTHROPIC_API_KEY=".count))
                        if !value.isEmpty {
                            _ = KeychainService.saveAPIKey(value)
                            print("[Debug] API key loaded from .env")
                            return
                        }
                    }
                }
            }
            dir = dir.deletingLastPathComponent()
        }
    }
    #endif
}
