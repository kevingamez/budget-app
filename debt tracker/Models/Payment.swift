import Foundation
import SwiftData

@Model
final class Payment {
    var id: UUID = UUID()
    var amount: Decimal = 0
    var date: Date = Date()
    var notes: String?
    var createdAt: Date = Date()

    var debt: Debt?

    init(
        amount: Decimal,
        date: Date = Date(),
        notes: String? = nil,
        debt: Debt? = nil
    ) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.notes = notes
        self.debt = debt
        self.createdAt = Date()
    }
}
