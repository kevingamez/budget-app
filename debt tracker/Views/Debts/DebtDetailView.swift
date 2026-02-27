import SwiftUI
import SwiftData

private let S = AppStrings.shared

struct DebtDetailView: View {
    let debt: Debt
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = DebtDetailViewModel()

    var body: some View {
        ZStack {
            ColorTokens.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    headerCard

                    // Person Info
                    if let person = debt.person {
                        personCard(person)
                    }

                    // Debt Info
                    debtInfoCard

                    // Payment History
                    paymentHistorySection

                    // Actions
                    actionsSection
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.bottom, 100)
            }

            // Record Payment Button
            if debt.derivedStatus != .paidOff && debt.derivedStatus != .forgiven {
                VStack {
                    Spacer()
                    Button {
                        viewModel.showPaymentSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text(S.tr("detail.recordPayment"))
                        }
                        .font(AppTypography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(ColorTokens.gradientForDirection(debt.direction), in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
                        .shadow(color: ColorTokens.colorForDirection(debt.direction).opacity(0.3), radius: 12, y: 6)
                    }
                    .pressable()
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationTitle("")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.showEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(ColorTokens.primaryAccent)
                }
            }
        }
        .sheet(isPresented: $viewModel.showPaymentSheet) {
            PaymentEntryView(debt: debt, viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showEditSheet) {
            EditDebtView(debt: debt)
        }
        .alert(S.tr("alert.deleteDebt.title"), isPresented: $viewModel.showDeleteConfirmation) {
            Button(S.tr("common.cancel"), role: .cancel) {}
            Button(S.tr("common.delete"), role: .destructive) {
                viewModel.deleteDebt(debt, context: modelContext)
                dismiss()
            }
        } message: {
            Text(S.tr("alert.deleteDebt.message"))
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 16) {
            // Direction Badge
            Text(debt.direction.label)
                .font(AppTypography.caption)
                .foregroundStyle(ColorTokens.colorForDirection(debt.direction))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(ColorTokens.colorForDirection(debt.direction).opacity(0.15), in: Capsule())

            // Amount
            Text(debt.totalAmount.currencyFormatted)
                .font(AppTypography.amountLarge)
                .foregroundStyle(ColorTokens.textPrimary)
                .contentTransition(.numericText())

            // Title
            Text(debt.title)
                .font(AppTypography.headline)
                .foregroundStyle(ColorTokens.textSecondary)

            // Progress
            if debt.derivedStatus != .forgiven {
                VStack(spacing: 8) {
                    AnimatedProgressBar(
                        progress: debt.progressFraction,
                        gradient: ColorTokens.gradientForDirection(debt.direction),
                        height: 10
                    )

                    HStack {
                        Text(S.tr("detail.paid", debt.paidAmount.currencyFormatted))
                            .font(AppTypography.caption)
                            .foregroundStyle(ColorTokens.textSecondary)
                        Spacer()
                        Text(S.tr("detail.remaining", debt.remainingAmount.currencyFormatted))
                            .font(AppTypography.caption)
                            .foregroundStyle(ColorTokens.textSecondary)
                    }
                }
            }

            // Status Badge
            statusBadge
        }
        .cardStyle()
    }

    private var statusBadge: some View {
        let status = debt.derivedStatus
        return Text(status.label)
            .font(AppTypography.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor(for: status), in: Capsule())
    }

    private func statusColor(for status: DebtStatus) -> Color {
        switch status {
        case .active: ColorTokens.primaryAccent
        case .partiallyPaid: ColorTokens.gold
        case .paidOff: ColorTokens.green
        case .overdue: ColorTokens.overdueColor
        case .forgiven: ColorTokens.textTertiary
        }
    }

    // MARK: - Person Card

    private func personCard(_ person: Person) -> some View {
        HStack(spacing: 14) {
            PersonAvatarView(person: person, size: .large)

            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(AppTypography.title3)
                    .foregroundStyle(ColorTokens.textPrimary)

                if let phone = person.phone {
                    Label(phone, systemImage: "phone.fill")
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.textSecondary)
                }
                if let email = person.email {
                    Label(email, systemImage: "envelope.fill")
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.textSecondary)
                }
            }

            Spacer()
        }
        .cardStyle()
    }

    // MARK: - Debt Info Card

    private var debtInfoCard: some View {
        VStack(spacing: 12) {
            infoRow(title: S.tr("detail.created"), value: debt.createdAt.shortFormatted, icon: "calendar")

            if let dueDate = debt.dueDate {
                infoRow(
                    title: S.tr("detail.dueDate"),
                    value: dueDate.shortFormatted,
                    icon: "clock.fill",
                    valueColor: debt.isOverdue ? ColorTokens.overdueColor : nil
                )
            }

            if let category = debt.category {
                infoRow(title: S.tr("detail.category"), value: category.name, icon: category.iconName)
            }

            if let notes = debt.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label(S.tr("detail.notes"), systemImage: "note.text")
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.textTertiary)
                    Text(notes)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(ColorTokens.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .cardStyle()
    }

    private func infoRow(title: String, value: String, icon: String, valueColor: Color? = nil) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(AppTypography.subheadline)
                .foregroundStyle(ColorTokens.textTertiary)
            Spacer()
            Text(value)
                .font(AppTypography.subheadline)
                .foregroundStyle(valueColor ?? ColorTokens.textPrimary)
        }
    }

    // MARK: - Payment History

    private var paymentHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(S.tr("detail.paymentHistory"))
                .font(AppTypography.headline)
                .foregroundStyle(ColorTokens.textPrimary)

            let payments = viewModel.sortedPayments(for: debt)

            if payments.isEmpty {
                Text(S.tr("detail.noPayments"))
                    .font(AppTypography.subheadline)
                    .foregroundStyle(ColorTokens.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(payments) { payment in
                    HStack {
                        Circle()
                            .fill(ColorTokens.green)
                            .frame(width: 8, height: 8)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(payment.amount.currencyFormatted)
                                .font(AppTypography.headline)
                                .foregroundStyle(ColorTokens.textPrimary)
                            if let notes = payment.notes {
                                Text(notes)
                                    .font(AppTypography.caption)
                                    .foregroundStyle(ColorTokens.textTertiary)
                            }
                        }

                        Spacer()

                        Text(payment.date.relativeFormatted)
                            .font(AppTypography.caption)
                            .foregroundStyle(ColorTokens.textSecondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 12) {
            if debt.derivedStatus != .paidOff && debt.derivedStatus != .forgiven {
                Button {
                    withAnimation {
                        viewModel.markAsForgiven(debt)
                    }
                } label: {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text(S.tr("detail.forgiveDebt"))
                    }
                    .font(AppTypography.headline)
                    .foregroundStyle(ColorTokens.gold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ColorTokens.gold.opacity(0.15), in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
                }
                .pressable()
            }

            Button {
                viewModel.showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text(S.tr("detail.deleteDebt"))
                }
                .font(AppTypography.headline)
                .foregroundStyle(ColorTokens.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(ColorTokens.red.opacity(0.15), in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
            }
            .pressable()
        }
    }
}
