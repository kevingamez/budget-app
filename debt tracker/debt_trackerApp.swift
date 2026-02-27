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
    #endif
}
