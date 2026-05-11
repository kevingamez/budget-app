import Testing
import Foundation
import SwiftData
@testable import debt_tracker

@MainActor
@Suite("Debt model")
struct DebtModelTests {
    /// @Model classes work as plain Swift objects for property access when not yet
    /// inserted into a ModelContext, so for these tests we exercise the computed
    /// properties (`paidAmount`, `remainingAmount`, `isOverdue`, `derivedStatus`)
    /// directly without standing up a ModelContainer. This avoids cross-talk with
    /// the host app's container (which is created on launch by `debt_trackerApp`).

    @Test("derivedStatus is .paidOff when remainingAmount <= 0")
    func paidOffWhenRemainderZero() {
        let person = Person(name: "Test")
        let debt = Debt(title: "Loan", totalAmount: 100, direction: .owedToMe, person: person)
        let payment = Payment(amount: 100, date: .now, debt: debt)
        debt.payments.append(payment)
        #expect(debt.paidAmount == 100)
        #expect(debt.remainingAmount == 0)
        #expect(debt.derivedStatus == .paidOff)
    }

    @Test("derivedStatus is .partiallyPaid when paidAmount > 0 and remainingAmount > 0")
    func partiallyPaidWhenSomePaid() {
        let person = Person(name: "Test")
        let debt = Debt(title: "Loan", totalAmount: 100, direction: .owedToMe, person: person)
        let payment = Payment(amount: 40, date: .now, debt: debt)
        debt.payments.append(payment)
        #expect(debt.paidAmount == 40)
        #expect(debt.remainingAmount == 60)
        #expect(debt.derivedStatus == .partiallyPaid)
    }

    @Test("derivedStatus is .forgiven when stored status is .forgiven (even if remainder > 0)")
    func forgivenOverridesEverything() {
        let person = Person(name: "Test")
        let debt = Debt(title: "Loan", totalAmount: 100, direction: .owedToMe, person: person)
        debt.status = .forgiven
        #expect(debt.derivedStatus == .forgiven)
    }

    @Test("derivedStatus is .overdue when past dueDate and unpaid")
    func overdueWhenPastDueDate() {
        let person = Person(name: "Test")
        let pastDate = Date().addingTimeInterval(-86_400 * 7)
        let debt = Debt(title: "Loan", totalAmount: 100, direction: .owedToMe, person: person, dueDate: pastDate)
        #expect(debt.isOverdue == true)
        #expect(debt.derivedStatus == .overdue)
    }

    @Test("derivedStatus is .active when nothing else applies")
    func activeWhenNothingElseApplies() {
        let person = Person(name: "Test")
        let futureDate = Date().addingTimeInterval(86_400 * 30)
        let debt = Debt(title: "Loan", totalAmount: 100, direction: .owedToMe, person: person, dueDate: futureDate)
        #expect(debt.paidAmount == 0)
        #expect(debt.remainingAmount == 100)
        #expect(debt.isOverdue == false)
        #expect(debt.derivedStatus == .active)
    }
}
