//
//  ContentView.swift
//  debt tracker
//
//  Created by Kevin Gamez on 2/27/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView(selectedTab: $selectedTab)
                    .background(ColorTokens.background)
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(AppAnimations.sheetSpring, value: hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Debt.self, Payment.self, Person.self, DebtCategory.self], inMemory: true)
}
