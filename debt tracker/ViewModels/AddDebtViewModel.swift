import Foundation
import SwiftData
import os

private let addDebtLog = Logger(subsystem: "kevingamez.debt-tracker", category: "addDebt")

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

    /// Injected so tests can swap a deterministic fake. Defaults to the
    /// process-wide singleton so production callers (`@State private var
    /// viewModel = AddDebtViewModel()`) keep working unchanged.
    private let notifications: any NotificationServiceProtocol

    init(notifications: any NotificationServiceProtocol = NotificationService.shared) {
        self.notifications = notifications
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && parsedAmount > 0
    }

    /// Clamped to the safe `[0, InputBounds.maxAmount]` range. Parses
    /// locale-aware so comma-decimal input ("5,50") isn't silently inflated.
    var parsedAmount: Decimal {
        InputBounds.clamp(amount: AmountInput.parse(amountString) ?? 0)
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
        } else {
            let bounded = InputBounds.bounded(newPersonName, max: InputBounds.titleMaxLength)
            if !bounded.isEmpty {
                let newPerson = Person(name: bounded)
                context.insert(newPerson)
                person = newPerson
            } else {
                person = nil
            }
        }

        let boundedTitle = InputBounds.bounded(title, max: InputBounds.titleMaxLength)
        let boundedNotes: String? = {
            let trimmed = InputBounds.bounded(notes, max: InputBounds.notesMaxLength)
            return trimmed.isEmpty ? nil : trimmed
        }()

        let debt = Debt(
            title: boundedTitle,
            totalAmount: parsedAmount,
            direction: direction,
            person: person,
            category: selectedCategory,
            dueDate: hasDueDate ? dueDate : nil,
            notes: boundedNotes,
            reminderEnabled: reminderEnabled,
            reminderDate: reminderEnabled ? reminderDate : nil
        )

        context.insert(debt)
        do {
            try context.save()
        } catch {
            // Roll back the orphaned insert and bail; surfacing through the log
            // beats silently dropping the user's input.
            addDebtLog.error("Failed to save debt: \(String(describing: error), privacy: .public)")
            context.rollback()
            return
        }

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
                let notifId = await notifications.scheduleReminder(
                    id: debtID,
                    personName: personName,
                    title: debtTitle,
                    direction: debtDirection,
                    reminderDate: scheduledDate,
                    existingIdentifier: nil
                )
                debt.notificationIdentifier = notifId
                do {
                    try context.save()
                } catch {
                    addDebtLog.error("Failed to persist notification id: \(String(describing: error), privacy: .public)")
                }
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
