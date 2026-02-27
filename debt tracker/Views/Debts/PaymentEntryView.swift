import SwiftUI

private let S = AppStrings.shared

struct PaymentEntryView: View {
    let debt: Debt
    @Bindable var viewModel: DebtDetailViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ColorTokens.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Debt Summary
                        VStack(spacing: 8) {
                            Text(debt.personName)
                                .font(AppTypography.headline)
                                .foregroundStyle(ColorTokens.textSecondary)

                            Text(debt.title)
                                .font(AppTypography.subheadline)
                                .foregroundStyle(ColorTokens.textTertiary)

                            Text(S.tr("payment.remaining", debt.remainingAmount.currencyFormatted))
                                .font(AppTypography.amountSmall)
                                .foregroundStyle(ColorTokens.colorForDirection(debt.direction))
                        }
                        .frame(maxWidth: .infinity)
                        .cardStyle()

                        // Amount Input
                        VStack(spacing: 12) {
                            AmountTextField(text: $viewModel.paymentAmountString)

                            Button {
                                viewModel.fillFullAmount(for: debt)
                            } label: {
                                Text(S.tr("payment.payFullAmount"))
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(ColorTokens.primaryAccent)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(ColorTokens.primaryAccent.opacity(0.15), in: Capsule())
                            }
                        }

                        // Date
                        DatePicker(S.tr("payment.paymentDate"), selection: $viewModel.paymentDate, displayedComponents: .date)
                            .font(AppTypography.body)
                            .foregroundStyle(ColorTokens.textPrimary)
                            .tint(ColorTokens.primaryAccent)
                            .padding(12)
                            .background(ColorTokens.surfaceElevated, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))

                        // Notes
                        TextField(S.tr("payment.notesPlaceholder"), text: $viewModel.paymentNotes, axis: .vertical)
                            .font(AppTypography.body)
                            .foregroundStyle(ColorTokens.textPrimary)
                            .lineLimit(2...4)
                            .padding(12)
                            .background(ColorTokens.surfaceElevated, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))

                        // Save Button
                        Button {
                            viewModel.recordPayment(for: debt, context: modelContext)
                            dismiss()
                        } label: {
                            Text(S.tr("detail.recordPayment"))
                                .font(AppTypography.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    viewModel.isPaymentValid
                                        ? AnyShapeStyle(ColorTokens.gradientForDirection(debt.direction))
                                        : AnyShapeStyle(ColorTokens.surfaceElevated),
                                    in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                )
                        }
                        .disabled(!viewModel.isPaymentValid)
                        .pressable()
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(S.tr("payment.title"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(S.tr("common.cancel")) {
                        viewModel.resetPaymentFields()
                        dismiss()
                    }
                    .foregroundStyle(ColorTokens.textSecondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
