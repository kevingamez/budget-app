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
    private var authService = SupabaseAuthService.shared

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else if !authService.isAuthenticated {
                AuthView()
                    .transition(.opacity)
            } else {
                MainTabView(selectedTab: $selectedTab)
                    .background(ColorTokens.background)
                    .transition(.opacity)
            }
        }
        .animation(AppAnimations.sheetSpring, value: hasCompletedOnboarding)
        .animation(AppAnimations.sheetSpring, value: authService.isAuthenticated)
        .task {
            await authService.refreshSession()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Debt.self, Payment.self, Person.self, DebtCategory.self], inMemory: true)
}
