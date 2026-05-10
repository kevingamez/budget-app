import SwiftUI

private let S = AppStrings.shared

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case debts
    case activity
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: S.tr("tab.dashboard")
        case .debts: S.tr("tab.debts")
        case .activity: S.tr("tab.activity")
        case .settings: S.tr("tab.settings")
        }
    }

    var icon: String {
        switch self {
        case .dashboard: "chart.bar.fill"
        case .debts: "dollarsign.circle.fill"
        case .activity: "clock.fill"
        case .settings: "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.dashboard.title, systemImage: AppTab.dashboard.icon, value: .dashboard) {
                DashboardView()
            }

            Tab(AppTab.debts.title, systemImage: AppTab.debts.icon, value: .debts) {
                DebtsListView()
            }

            Tab(AppTab.activity.title, systemImage: AppTab.activity.icon, value: .activity) {
                ActivityFeedView()
            }

            Tab(AppTab.settings.title, systemImage: AppTab.settings.icon, value: .settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(ColorTokens.primaryAccent)
        .onReceive(NotificationCenter.default.publisher(for: .newDebtRequested)) { _ in
            // Surface the New Debt form (used by ⌘N on macOS). Switch to the
            // debts tab; the list view re-emits this notification to open the sheet.
            selectedTab = .debts
        }
    }
}
