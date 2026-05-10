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
}

@main
struct debt_trackerApp: App {
    let container: ModelContainer = {
        do {
            return try ModelContainer(for: Debt.self, Payment.self, Person.self, DebtCategory.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
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
                .preferredColorScheme(.dark)
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
