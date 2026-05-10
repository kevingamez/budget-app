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
        try? context.save()

        // Schedule notification if reminder enabled.
        // We hop onto the MainActor (Debt is @MainActor-isolated) and persist the
        // identifier with a follow-up save once the async schedule completes.
        if reminderEnabled {
            let personName = person?.name ?? "Someone"
            let debtTitle = debt.title
            let debtDirection = direction
            let scheduledDate = reminderDate
            let debtID = debt.id.uuidString
            Task { @MainActor in
                let notifId = await NotificationService.shared.scheduleReminder(
                    id: debtID,
                    personName: personName,
                    title: debtTitle,
                    direction: debtDirection,
                    reminderDate: scheduledDate,
                    existingIdentifier: nil
                )
                debt.notificationIdentifier = notifId
                try? context.save()
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
