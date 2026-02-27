import Foundation
import SwiftData

private let S = AppStrings.shared

enum DebtSortOption: String, CaseIterable, Identifiable {
    case dateCreated
    case dueDate
    case amount
    case personName

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dateCreated: S.tr("sort.dateCreated")
        case .dueDate: S.tr("sort.dueDate")
        case .amount: S.tr("sort.amount")
        case .personName: S.tr("sort.person")
        }
    }
}

@Observable
final class DebtsListViewModel {
    var filterDirection: DebtDirection?
    var searchText: String = ""
    var sortOption: DebtSortOption = .dateCreated
    var showAddDebt: Bool = false

    func filteredDebts(from allDebts: [Debt]) -> [Debt] {
        var result = allDebts

        // Filter by direction
        if let direction = filterDirection {
            result = result.filter { $0.direction == direction }
        }

        // Filter by search text
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.personName.lowercased().contains(query) ||
                ($0.category?.name.lowercased().contains(query) ?? false)
            }
        }

        // Sort
        switch sortOption {
        case .dateCreated:
            result.sort { $0.createdAt > $1.createdAt }
        case .dueDate:
            result.sort { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        case .amount:
            result.sort { $0.totalAmount > $1.totalAmount }
        case .personName:
            result.sort { $0.personName.lowercased() < $1.personName.lowercased() }
        }

        return result
    }

    func deleteDebt(_ debt: Debt, context: ModelContext) {
        context.delete(debt)
    }

    func markAsPaid(_ debt: Debt, context: ModelContext) {
        let remaining = debt.remainingAmount
        guard remaining > 0 else { return }

        let payment = Payment(amount: remaining, date: Date(), notes: S.tr("payment.paidInFull"), debt: debt)
        context.insert(payment)
        debt.status = .paidOff
        debt.updatedAt = Date()
    }
}
