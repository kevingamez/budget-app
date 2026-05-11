import SwiftUI
import SwiftData

private let S = AppStrings.shared

struct DashboardView: View {
    @Query(sort: \Debt.createdAt, order: .reverse) private var debts: [Debt]
    @Query(sort: \Payment.date, order: .reverse) private var payments: [Payment]
    @Query private var persons: [Person]
    @State private var viewModel = DashboardViewModel()
    @State private var selectedInsight: InsightRequest?

    var body: some View {
        NavigationStack {
            ZStack {
                ColorTokens.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        topBar
                            .staggeredAppear(index: 0)

                        HeroBalanceView(
                            netBalance: viewModel.netBalance,
                            owedToMe: viewModel.totalOwedToMe,
                            iOwe: viewModel.totalIOwe
                        )
                        .staggeredAppear(index: 1)

                        QuickActionsRow(actions: quickActions)
                            .staggeredAppear(index: 2)

                        AccountCardsRow(
                            owedToMe: viewModel.totalOwedToMe,
                            iOwe: viewModel.totalIOwe,
                            activeCount: viewModel.activeDebtCount,
                            overdueCount: viewModel.overdueCount
                        )
                        .staggeredAppear(index: 3)

                        InsightTilesRow(
                            activeCount: viewModel.activeDebtCount,
                            overdueCount: viewModel.overdueCount,
                            almostPaidCount: viewModel.topDebts.count
                        )
                        .staggeredAppear(index: 4)

                        TransactionsListSection(
                            payments: viewModel.recentPayments,
                            onSeeAll: {
                                NotificationCenter.default.post(
                                    name: .requestTabSwitch,
                                    object: AppTab.activity
                                )
                            }
                        )
                        .staggeredAppear(index: 5)

                        lifetimeStatsSection
                            .staggeredAppear(index: 6)
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("")
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .onAppear {
                viewModel.refresh(debts: debts, payments: payments)
            }
            .task(id: contentSignature) {
                viewModel.refresh(debts: debts, payments: payments)
            }
            .sheet(item: $selectedInsight) { request in
                AIInsightsSheetView(snapshot: request.snapshot, cardGradient: request.gradient)
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(ColorTokens.primaryGradient)
                .frame(width: 36, height: 36)
                .overlay(
                    Text(initialsForGreeting)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 0) {
                Text(greetingText)
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .foregroundStyle(ColorTokens.textTertiary)
                Text(S.tr("greeting.subtitle"))
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(ColorTokens.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                NotificationCenter.default.post(name: .requestTabSwitch, object: AppTab.settings)
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(ColorTokens.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(ColorTokens.surface, in: Circle())
                    .overlay(Circle().stroke(ColorTokens.surfaceBorder, lineWidth: 0.5))
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var lifetimeStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ColorTokens.textTertiary)
                Text(S.tr("dashboard.lifetimeStats"))
                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                    .tracking(1.0)
                    .foregroundStyle(ColorTokens.textTertiary)
            }

            StatsView(
                totalDebts: debts.count,
                totalAmountTracked: viewModel.totalAmountTracked,
                totalPaidOff: viewModel.paidOffCount,
                averageAmount: viewModel.averageAmount,
                totalPersons: persons.count,
                totalPayments: payments.count,
                totalPaymentAmount: viewModel.totalPaymentAmount,
                debts: debts,
                persons: persons,
                onCardTapped: { snapshot, gradient in
                    selectedInsight = InsightRequest(snapshot: snapshot, gradient: gradient)
                }
            )
        }
    }

    // MARK: - Helpers

    private var quickActions: [QuickAction] {
        [
            QuickAction(label: S.tr("dashboard.actionNew"), icon: "plus") {
                NotificationCenter.default.post(name: .newDebtRequested, object: nil)
            },
            QuickAction(label: S.tr("dashboard.actionPay"), icon: "checkmark") {
                NotificationCenter.default.post(name: .requestTabSwitch, object: AppTab.debts)
            },
            QuickAction(label: S.tr("dashboard.actionPeople"), icon: "person.2.fill") {
                NotificationCenter.default.post(name: .requestTabSwitch, object: AppTab.debts)
            },
            QuickAction(label: S.tr("dashboard.actionMore"), icon: "ellipsis") {
                NotificationCenter.default.post(name: .requestTabSwitch, object: AppTab.settings)
            },
        ]
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return S.tr("greeting.morning") }
        if hour < 17 { return S.tr("greeting.afternoon") }
        return S.tr("greeting.evening")
    }

    private var initialsForGreeting: String {
        let trimmed = greetingText.trimmingCharacters(in: .whitespaces)
        return String(trimmed.prefix(1)).uppercased()
    }

    /// Cheap snapshot of content that triggers VM refresh when it changes.
    private var contentSignature: Int {
        var hash = 0
        hash ^= debts.count
        hash ^= payments.count &<< 1
        for debt in debts {
            hash ^= debt.persistentModelID.hashValue
            hash ^= debt.totalAmount.hashValue
        }
        for payment in payments {
            hash ^= payment.persistentModelID.hashValue
            hash ^= payment.amount.hashValue
        }
        return hash
    }
}
