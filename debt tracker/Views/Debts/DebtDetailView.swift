import SwiftUI
import SwiftData

private let S = AppStrings.shared

/// Detail screen for a single debt — composes the per-section views.
struct DebtDetailView: View {
    let debt: Debt
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = DebtDetailViewModel()

    private var canRecordPayment: Bool {
        debt.derivedStatus != .paidOff && debt.derivedStatus != .forgiven
    }

    var body: some View {
        ZStack {
            ColorTokens.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    DebtDetailHeaderCard(debt: debt)

                    if let person = debt.person {
                        DebtPersonCard(person: person)
                    }

                    DebtInfoCard(debt: debt)

                    PaymentHistorySection(payments: viewModel.sortedPayments(for: debt))

                    DebtActionsSection(
                        canForgive: canRecordPayment,
                        onForgive: { viewModel.markAsForgiven(debt, context: modelContext) },
                        onDelete: { viewModel.showDeleteConfirmation = true }
                    )
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.bottom, 100)
            }

            if canRecordPayment {
                recordPaymentFloatingButton
            }
        }
        .navigationTitle("")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar { editToolbar }
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

    @ToolbarContentBuilder
    private var editToolbar: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button {
                viewModel.showEditSheet = true
            } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(ColorTokens.primaryAccent)
            }
            .accessibilityLabel(S.tr("common.edit"))
        }
    }

    private var recordPaymentFloatingButton: some View {
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
                .background(
                    ColorTokens.gradientForDirection(debt.direction),
                    in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                )
                .shadow(color: ColorTokens.colorForDirection(debt.direction).opacity(0.3), radius: 12, y: 6)
            }
            .pressable()
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.bottom, 16)
        }
    }
}
