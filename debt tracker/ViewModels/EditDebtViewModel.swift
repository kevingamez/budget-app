import Foundation
import SwiftData

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
        !title.trimmingCharacters(in: .whitespaces).isEmpty && totalAmount > 0
    }

    func save(context: ModelContext) {
        guard let debt = context.model(for: debtID) as? Debt else { return }
        debt.title = title.trimmingCharacters(in: .whitespaces)
        debt.totalAmount = totalAmount
        debt.direction = direction
        debt.dueDate = hasDueDate ? dueDate : nil
        debt.notes = notes.isEmpty ? nil : notes
        debt.category = category
        debt.updatedAt = Date()
        try? context.save()
    }
}
