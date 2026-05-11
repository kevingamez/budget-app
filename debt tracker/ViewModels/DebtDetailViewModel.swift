import Foundation
import SwiftData
import os

private let debtDetailLog = Logger(subsystem: "kevingamez.debt-tracker", category: "debtDetail")

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
        InputBounds.clamp(amount: Decimal(string: paymentAmountString) ?? 0)
    }

    var isPaymentValid: Bool {
        parsedPaymentAmount > 0
    }

    // kept in sync with DebtsListViewModel.markAsPaid
    func recordPayment(for debt: Debt, context: ModelContext) {
        // Cap the payment at remainingAmount so the user can't accidentally
        // (or maliciously) drive the balance negative — that would corrupt
        // derivedStatus and break the dashboard totals.
        let requested = parsedPaymentAmount
        let amount = min(requested, debt.remainingAmount)
        guard amount > 0 else { return }

        let boundedNotes = InputBounds.bounded(paymentNotes, max: InputBounds.notesMaxLength)

        let payment = Payment(
            amount: amount,
            date: paymentDate,
            notes: boundedNotes.isEmpty ? nil : boundedNotes,
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

        do {
            try context.save()
            resetPaymentFields()
        } catch {
            debtDetailLog.error("recordPayment save failed: \(String(describing: error), privacy: .public)")
            context.rollback()
        }
    }

    func markAsForgiven(_ debt: Debt, context: ModelContext) {
        debt.status = .forgiven
        debt.updatedAt = Date()
        if let identifier = debt.notificationIdentifier {
            NotificationService.shared.cancelReminder(identifier: identifier)
            debt.notificationIdentifier = nil
        }
        do {
            try context.save()
        } catch {
            debtDetailLog.error("markAsForgiven save failed: \(String(describing: error), privacy: .public)")
            context.rollback()
        }
    }

    func deleteDebt(_ debt: Debt, context: ModelContext) {
        if let identifier = debt.notificationIdentifier {
            NotificationService.shared.cancelReminder(identifier: identifier)
        }
        context.delete(debt)
        do {
            try context.save()
        } catch {
            debtDetailLog.error("deleteDebt save failed: \(String(describing: error), privacy: .public)")
            context.rollback()
        }
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
