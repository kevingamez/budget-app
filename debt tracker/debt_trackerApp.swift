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
}
