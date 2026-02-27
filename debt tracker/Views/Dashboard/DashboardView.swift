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
                        // Greeting
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

                        // Balance Overview
                        BalanceOverviewCard(
                            totalOwedToMe: viewModel.totalOwedToMe,
                            totalIOwe: viewModel.totalIOwe,
                            netBalance: viewModel.netBalance
                        )
                        .staggeredAppear(index: 1, appeared: appeared)

                        // Summary Cards Row
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

                        // Progress Card
                        DebtProgressCard(debts: viewModel.topDebts)
                            .staggeredAppear(index: 3, appeared: appeared)

                        // Recent Activity
                        RecentActivityCard(payments: viewModel.recentPayments)
                            .staggeredAppear(index: 4, appeared: appeared)

                        // Lifetime Stats
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
                                totalAmountTracked: debts.reduce(Decimal.zero) { $0 + $1.totalAmount },
                                totalPaidOff: debts.filter { $0.derivedStatus == .paidOff || $0.derivedStatus == .forgiven }.count,
                                averageAmount: debts.isEmpty ? 0 : debts.reduce(Decimal.zero) { $0 + $1.totalAmount } / Decimal(debts.count),
                                totalPersons: persons.count,
                                totalPayments: payments.count,
                                totalPaymentAmount: payments.reduce(Decimal.zero) { $0 + $1.amount },
                                debts: debts,
                                persons: persons,
                                onCardTapped: { snapshot, gradient in
                                    selectedInsight = InsightRequest(snapshot: snapshot, gradient: gradient)
                                }
                            )
                        }
                        .staggeredAppear(index: 5, appeared: appeared)
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
            .onChange(of: debts.count) {
                viewModel.refresh(debts: debts, payments: payments)
            }
            .onChange(of: payments.count) {
                viewModel.refresh(debts: debts, payments: payments)
            }
            .sheet(item: $selectedInsight) { request in
                AIInsightsSheetView(snapshot: request.snapshot, cardGradient: request.gradient)
            }
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return S.tr("greeting.morning") }
        if hour < 17 { return S.tr("greeting.afternoon") }
        return S.tr("greeting.evening")
    }
}
