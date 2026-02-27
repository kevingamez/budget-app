import Foundation
import SwiftData

@Observable
final class DebtDetailViewModel {
    var showPaymentSheet = false
    var showEditSheet = false
    var showDeleteConfirmation = false

    // Payment entry fields
    var paymentAmountString: String = ""
    var paymentDate: Date = Date()
    var paymentNotes: String = ""

    var parsedPaymentAmount: Decimal {
        Decimal(string: paymentAmountString) ?? 0
    }

    var isPaymentValid: Bool {
        parsedPaymentAmount > 0
    }

    func recordPayment(for debt: Debt, context: ModelContext) {
        let amount = parsedPaymentAmount
        guard amount > 0 else { return }

        let payment = Payment(
            amount: amount,
            date: paymentDate,
            notes: paymentNotes.isEmpty ? nil : paymentNotes,
            debt: debt
        )
        context.insert(payment)
        debt.updatedAt = Date()

        // Update status
        if debt.remainingAmount <= amount {
            debt.status = .paidOff
        } else if debt.status == .active {
            debt.status = .partiallyPaid
        }

        resetPaymentFields()
    }

    func markAsForgiven(_ debt: Debt) {
        debt.status = .forgiven
        debt.updatedAt = Date()
    }

    func deleteDebt(_ debt: Debt, context: ModelContext) {
        context.delete(debt)
    }

    func fillFullAmount(for debt: Debt) {
        paymentAmountString = NSDecimalNumber(decimal: debt.remainingAmount).stringValue
    }

    func resetPaymentFields() {
        paymentAmountString = ""
        paymentDate = Date()
        paymentNotes = ""
    }

    func sortedPayments(for debt: Debt) -> [Payment] {
        debt.payments.sorted { $0.date > $1.date }
    }
}
