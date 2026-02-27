import Foundation
import SwiftData

@Observable
final class AddDebtViewModel {
    var title: String = ""
    var amountString: String = ""
    var direction: DebtDirection = .owedToMe
    var selectedPerson: Person?
    var newPersonName: String = ""
    var selectedCategory: DebtCategory?
    var hasDueDate: Bool = false
    var dueDate: Date = Date().addingTimeInterval(7 * 24 * 60 * 60)
    var notes: String = ""
    var reminderEnabled: Bool = false
    var reminderDate: Date = Date()

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && parsedAmount > 0
    }

    var parsedAmount: Decimal {
        Decimal(string: amountString) ?? 0
    }

    var personDisplayName: String {
        if let person = selectedPerson {
            return person.name
        } else if !newPersonName.isEmpty {
            return newPersonName
        }
        return ""
    }

    func save(context: ModelContext) {
        // Create or use existing person
        let person: Person?
        if let existing = selectedPerson {
            person = existing
        } else if !newPersonName.trimmingCharacters(in: .whitespaces).isEmpty {
            let newPerson = Person(name: newPersonName.trimmingCharacters(in: .whitespaces))
            context.insert(newPerson)
            person = newPerson
        } else {
            person = nil
        }

        let debt = Debt(
            title: title.trimmingCharacters(in: .whitespaces),
            totalAmount: parsedAmount,
            direction: direction,
            person: person,
            category: selectedCategory,
            dueDate: hasDueDate ? dueDate : nil,
            notes: notes.isEmpty ? nil : notes,
            reminderEnabled: reminderEnabled,
            reminderDate: reminderEnabled ? reminderDate : nil
        )

        context.insert(debt)

        // Schedule notification if reminder enabled
        if reminderEnabled {
            Task {
                let notifId = await NotificationService.shared.scheduleReminder(
                    id: debt.id.uuidString,
                    personName: person?.name ?? "Someone",
                    title: debt.title,
                    direction: direction,
                    reminderDate: reminderDate,
                    existingIdentifier: nil
                )
                debt.notificationIdentifier = notifId
            }
        }
    }

    func reset() {
        title = ""
        amountString = ""
        direction = .owedToMe
        selectedPerson = nil
        newPersonName = ""
        selectedCategory = nil
        hasDueDate = false
        dueDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
        notes = ""
        reminderEnabled = false
        reminderDate = Date()
    }
}
