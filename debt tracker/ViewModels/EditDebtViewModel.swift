import Foundation
import SwiftData
import os

private let editDebtLog = Logger(subsystem: "kevingamez.debt-tracker", category: "editDebt")

@Observable
final class EditDebtViewModel {
    var title: String
    var totalAmount: Decimal
    var amountString: String
    var direction: DebtDirection
    var hasDueDate: Bool
    var dueDate: Date
    var notes: String
    var category: DebtCategory?

    private let debtID: PersistentIdentifier

    init(debt: Debt) {
        self.debtID = debt.persistentModelID
        self.title = debt.title
        self.totalAmount = debt.totalAmount
        self.amountString = NSDecimalNumber(decimal: debt.totalAmount).stringValue
        self.direction = debt.direction
        self.hasDueDate = debt.dueDate != nil
        self.dueDate = debt.dueDate ?? Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        self.notes = debt.notes ?? ""
        self.category = debt.category
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && InputBounds.clamp(amount: totalAmount) > 0
    }

    func save(context: ModelContext) {
        guard let debt = context.model(for: debtID) as? Debt else { return }
        debt.title = InputBounds.bounded(title, max: InputBounds.titleMaxLength)
        debt.totalAmount = InputBounds.clamp(amount: totalAmount)
        debt.direction = direction
        debt.dueDate = hasDueDate ? dueDate : nil
        let trimmedNotes = InputBounds.bounded(notes, max: InputBounds.notesMaxLength)
        debt.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
        debt.category = category
        debt.updatedAt = Date()
        do {
            try context.save()
        } catch {
            editDebtLog.error("Failed to save edit: \(String(describing: error), privacy: .public)")
            context.rollback()
        }
    }
}
