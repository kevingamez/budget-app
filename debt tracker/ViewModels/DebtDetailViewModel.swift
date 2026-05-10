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

    // kept in sync with DebtsListViewModel.markAsPaid
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
        // Do not mutate debt.status — derivedStatus computes .paidOff / .partiallyPaid from payments.

        // Cancel reminder if this payment fully pays off the debt.
        if debt.remainingAmount <= 0, let identifier = debt.notificationIdentifier {
            NotificationService.shared.cancelReminder(identifier: identifier)
            debt.notificationIdentifier = nil
        }

        try? context.save()
        resetPaymentFields()
    }

    func markAsForgiven(_ debt: Debt) {
        debt.status = .forgiven
        debt.updatedAt = Date()
        if let identifier = debt.notificationIdentifier {
            NotificationService.shared.cancelReminder(identifier: identifier)
            debt.notificationIdentifier = nil
        }
    }

    func deleteDebt(_ debt: Debt, context: ModelContext) {
        if let identifier = debt.notificationIdentifier {
            NotificationService.shared.cancelReminder(identifier: identifier)
        }
        context.delete(debt)
        try? context.save()
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
