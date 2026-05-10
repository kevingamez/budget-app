import SwiftUI
import SwiftData

private let S = AppStrings.shared

struct DashboardView: View {
    @Query(sort: \Debt.createdAt, order: .reverse) private var debts: [Debt]
    @Query(sort: \Payment.date, order: .reverse) private var payments: [Payment]
    @Query private var persons: [Person]
    @State private var viewModel = DashboardViewModel()
    @State private var appeared = false
    @State private var selectedInsight: InsightRequest?

    var body: some View {
        NavigationStack {
            ZStack {
                ColorTokens.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        greetingSection
                        balanceCard
                        summaryRow
                        progressSection
                        recentActivitySection
                        lifetimeStatsSection
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("")
            .onAppear {
                viewModel.refresh(debts: debts, payments: payments)
                withAnimation {
                    appeared = true
                }
            }
            // React to content changes (additions, edits, deletions) using a content signature.
            // Avoids staleness when a debt/payment is edited without count changes.
            .task(id: contentSignature) {
                viewModel.refresh(debts: debts, payments: payments)
            }
            .sheet(item: $selectedInsight) { request in
                AIInsightsSheetView(snapshot: request.snapshot, cardGradient: request.gradient)
            }
        }
    }

    // MARK: - Content Signature

    /// Cheap snapshot of content that triggers VM refresh when it changes.
    /// XORs persistent IDs and monetary amounts to catch additions, deletions, and edits.
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

    // MARK: - Sections

    @ViewBuilder
    private var greetingSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(AppTypography.title)
                    .foregroundStyle(ColorTokens.textPrimary)

                Text(S.tr("greeting.subtitle"))
                    .font(AppTypography.subheadline)
                    .foregroundStyle(ColorTokens.textSecondary)
            }
            Spacer()
        }
        .staggeredAppear(index: 0, appeared: appeared)
    }

    @ViewBuilder
    private var balanceCard: some View {
        BalanceOverviewCard(
            totalOwedToMe: viewModel.totalOwedToMe,
            totalIOwe: viewModel.totalIOwe,
            netBalance: viewModel.netBalance
        )
        .staggeredAppear(index: 1, appeared: appeared)
    }

    @ViewBuilder
    private var summaryRow: some View {
        HStack(spacing: 12) {
            SummaryCardView(
                title: S.tr("dashboard.activeDebts"),
                value: "\(viewModel.activeDebtCount)",
                icon: "doc.text.fill",
                gradient: ColorTokens.primaryGradient
            )

            SummaryCardView(
                title: S.tr("dashboard.overdue"),
                value: "\(viewModel.overdueCount)",
                icon: "exclamationmark.triangle.fill",
                gradient: viewModel.overdueCount > 0 ? ColorTokens.redGradient : ColorTokens.greenGradient
            )
        }
        .staggeredAppear(index: 2, appeared: appeared)
    }

    @ViewBuilder
    private var progressSection: some View {
        DebtProgressCard(debts: viewModel.topDebts)
            .staggeredAppear(index: 3, appeared: appeared)
    }

    @ViewBuilder
    private var recentActivitySection: some View {
        RecentActivityCard(payments: viewModel.recentPayments)
            .staggeredAppear(index: 4, appeared: appeared)
    }

    @ViewBuilder
    private var lifetimeStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ColorTokens.textTertiary)
                Text(S.tr("dashboard.lifetimeStats"))
                    .font(AppTypography.footnote)
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
        .staggeredAppear(index: 5, appeared: appeared)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return S.tr("greeting.morning") }
        if hour < 17 { return S.tr("greeting.afternoon") }
        return S.tr("greeting.evening")
    }
}
