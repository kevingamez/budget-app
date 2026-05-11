import Testing
import Foundation
import SwiftData
@testable import debt_tracker

@MainActor
@Suite("Debts list filtering")
struct DebtsListViewModelTests {
    private func sampleDebts() -> [Debt] {
        let alice = Person(name: "Alice")
        let bob = Person(name: "Bob")
        let dinerPerson = Person(name: "Dinner Club")
        let d1 = Debt(title: "Rent", totalAmount: 500, direction: .iOwe, person: alice)
        let d2 = Debt(title: "Lunch", totalAmount: 30, direction: .owedToMe, person: bob)
        let d3 = Debt(title: "Concert tickets", totalAmount: 120, direction: .owedToMe, person: dinerPerson)
        return [d1, d2, d3]
    }

    @Test("filteredDebts returns only direction=.owedToMe when filterDirection is set")
    func filteredDebtsByDirectionOwedToMe() {
        let debts = sampleDebts()
        let vm = DebtsListViewModel()
        vm.filterDirection = .owedToMe
        let result = vm.filteredDebts(from: debts)
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.direction == .owedToMe })
    }

    @Test("filteredDebts matches search text against title or person name")
    func filteredDebtsBySearchText() {
        let debts = sampleDebts()
        let vm = DebtsListViewModel()
        vm.searchText = "din"
        let result = vm.filteredDebts(from: debts)
        // Should match "Dinner Club" (person name) — that's the Concert tickets debt.
        #expect(result.count == 1)
        #expect(result.first?.title == "Concert tickets")
    }

    @Test("sortOption=.amount sorts by totalAmount descending")
    func sortByAmountDescending() {
        let debts = sampleDebts()
        let vm = DebtsListViewModel()
        vm.sortOption = .amount
        let result = vm.filteredDebts(from: debts)
        #expect(result.map(\.totalAmount) == [500, 120, 30])
    }
}
