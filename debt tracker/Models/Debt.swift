import Foundation
import SwiftData

@Model
final class Debt {
    var id: UUID = UUID()
    var title: String = ""
    var totalAmount: Decimal = 0
    var direction: DebtDirection = DebtDirection.owedToMe
    var status: DebtStatus = DebtStatus.active
    var dueDate: Date?
    var notes: String?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var reminderEnabled: Bool = false
    var reminderDate: Date?
    var notificationIdentifier: String?

    // Relationships
    var person: Person?
    var category: DebtCategory?

    @Relationship(deleteRule: .cascade, inverse: \Payment.debt)
    var payments: [Payment] = []

    // MARK: - Computed Properties

    var paidAmount: Decimal {
        payments.reduce(Decimal.zero) { $0 + $1.amount }
    }

    var remainingAmount: Decimal {
        max(totalAmount - paidAmount, Decimal.zero)
    }

    var progressFraction: Double {
        guard totalAmount > 0 else { return 0 }
        return NSDecimalNumber(decimal: paidAmount).doubleValue
            / NSDecimalNumber(decimal: totalAmount).doubleValue
    }

    var isOverdue: Bool {
        guard let dueDate, status != .paidOff, status != .forgiven else { return false }
        return dueDate < Date()
    }

    var derivedStatus: DebtStatus {
        if status == .forgiven { return .forgiven }
        if remainingAmount <= 0 { return .paidOff }
        if isOverdue { return .overdue }
        if paidAmount > 0 { return .partiallyPaid }
        return .active
    }

    var personName: String {
        person?.name ?? "Unknown"
    }

    init(
        title: String,
        totalAmount: Decimal,
        direction: DebtDirection,
        person: Person? = nil,
        category: DebtCategory? = nil,
        dueDate: Date? = nil,
        notes: String? = nil,
        reminderEnabled: Bool = false,
        reminderDate: Date? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.totalAmount = totalAmount
        self.direction = direction
        self.person = person
        self.category = category
        self.dueDate = dueDate
        self.notes = notes
        self.status = .active
        self.reminderEnabled = reminderEnabled
        self.reminderDate = reminderDate
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
