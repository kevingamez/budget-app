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
    @AppStorage("requireBiometrics") private var requireBiometrics = false
    @State private var selectedTab: AppTab = .dashboard
    @Environment(\.scenePhase) private var scenePhase
    private var authService = SupabaseAuthService.shared
    private var themeManager = ThemeManager.shared
    private var biometric = BiometricAuthService.shared

    private var shouldRequireBiometrics: Bool {
        requireBiometrics && authService.isAuthenticated && hasCompletedOnboarding
    }

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else if !authService.isAuthenticated {
                AuthView()
                    .transition(.opacity)
            } else if shouldRequireBiometrics && !biometric.isUnlocked {
                BiometricLockScreen(onUnlock: {
                    // The service mutates `isUnlocked`; this body re-renders via Observation.
                })
                .transition(.opacity)
            } else {
                MainTabView(selectedTab: $selectedTab)
                    .background(ColorTokens.background)
                    .transition(.opacity)
            }
        }
        .id(themeManager.currentId)
        .preferredColorScheme(themeManager.current.preferredScheme)
        .animation(AppAnimations.sheetSpring, value: hasCompletedOnboarding)
        .animation(AppAnimations.sheetSpring, value: authService.isAuthenticated)
        .animation(AppAnimations.sheetSpring, value: biometric.isUnlocked)
        .task { await authService.refreshSession() }
        .onChange(of: scenePhase) { _, newPhase in
            // Re-lock the app whenever it leaves the active scene so returning
            // from background re-prompts biometrics.
            if newPhase == .background || newPhase == .inactive {
                if shouldRequireBiometrics { biometric.lock() }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Debt.self, Payment.self, Person.self, DebtCategory.self], inMemory: true)
}
