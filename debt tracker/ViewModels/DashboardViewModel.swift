import Foundation
import SwiftData

@Observable
final class DashboardViewModel {
    var totalOwedToMe: Decimal = 0
    var totalIOwe: Decimal = 0
    var netBalance: Decimal = 0
    var activeDebtCount: Int = 0
    var overdueCount: Int = 0
    var topDebts: [Debt] = []
    var recentPayments: [Payment] = []

    func refresh(debts: [Debt], payments: [Payment]) {
        let activeDebts = debts.filter { $0.derivedStatus != .paidOff && $0.derivedStatus != .forgiven }

        totalOwedToMe = activeDebts
            .filter { $0.direction == .owedToMe }
            .reduce(Decimal.zero) { $0 + $1.remainingAmount }

        totalIOwe = activeDebts
            .filter { $0.direction == .iOwe }
            .reduce(Decimal.zero) { $0 + $1.remainingAmount }

        netBalance = totalOwedToMe - totalIOwe

        activeDebtCount = activeDebts.count
        overdueCount = activeDebts.filter { $0.isOverdue }.count

        topDebts = activeDebts
            .filter { $0.progressFraction > 0 && $0.progressFraction < 1 }
            .sorted { $0.progressFraction > $1.progressFraction }
            .prefix(3)
            .map { $0 }

        recentPayments = payments
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }
    }
}
