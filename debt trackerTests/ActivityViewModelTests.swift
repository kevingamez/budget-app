import Testing
import Foundation
import SwiftData
@testable import debt_tracker

@MainActor
@Suite("Activity grouping")
struct ActivityViewModelTests {
    @Test("empty payments returns empty sections")
    func emptyPaymentsReturnsEmptySections() {
        let vm = ActivityViewModel()
        let sections = vm.groupedPayments(from: [])
        #expect(sections.isEmpty)
    }

    @Test("payments are grouped into distinct date buckets")
    func paymentsGroupedByBucket() {
        let person = Person(name: "Test")
        let debt = Debt(title: "Loan", totalAmount: 1000, direction: .owedToMe, person: person)

        let cal = Calendar.current
        let today = Date()

        let p1 = Payment(amount: 10, date: today, debt: debt)
        let p2 = Payment(amount: 10, date: today.addingTimeInterval(-86_400), debt: debt)
        let p3 = Payment(amount: 10, date: today.addingTimeInterval(-86_400 * 60), debt: debt)

        var payments: [Payment] = [p1, p2, p3]

        // Try to place a payment in the "this week" bucket that's not today or yesterday.
        let threeDaysAgo = today.addingTimeInterval(-86_400 * 3)
        if threeDaysAgo.isThisWeek && !threeDaysAgo.isToday && !threeDaysAgo.isYesterday {
            payments.append(Payment(amount: 10, date: threeDaysAgo, debt: debt))
        }

        let vm = ActivityViewModel()
        let sections = vm.groupedPayments(from: payments)
        // We always have today, yesterday, and earlier — at least 3 distinct buckets.
        #expect(sections.count >= 3)
        for section in sections {
            #expect(!section.payments.isEmpty)
        }
        let total = sections.reduce(0) { $0 + $1.payments.count }
        #expect(total == payments.count)
        // Ignore unused-warning on cal.
        _ = cal
    }

    @Test("filterDirection filters payments by debt direction")
    func filterDirectionFiltersByDebtDirection() {
        let person = Person(name: "Test")
        let owedToMe = Debt(title: "Owed", totalAmount: 100, direction: .owedToMe, person: person)
        let iOwe = Debt(title: "Mine", totalAmount: 100, direction: .iOwe, person: person)

        let p1 = Payment(amount: 10, date: .now, debt: owedToMe)
        let p2 = Payment(amount: 20, date: .now, debt: iOwe)

        let vm = ActivityViewModel()
        vm.filterDirection = .owedToMe
        let sections = vm.groupedPayments(from: [p1, p2])
        let allPayments = sections.flatMap(\.payments)
        #expect(allPayments.count == 1)
        #expect(allPayments.first?.debt?.direction == .owedToMe)
    }
}
