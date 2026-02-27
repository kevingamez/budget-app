import Foundation
import SwiftData

enum SampleDataService {
    static func seedCategories(context: ModelContext) {
        for type in DebtCategoryType.allCases {
            let category = DebtCategory(from: type)
            context.insert(category)
        }
    }

    static func seedSampleData(context: ModelContext) {
        // Categories
        let categories = DebtCategoryType.allCases.map { DebtCategory(from: $0) }
        categories.forEach { context.insert($0) }

        // People
        let people = [
            Person(name: "Alex Johnson", phone: "555-0101"),
            Person(name: "Maria Garcia", email: "maria@email.com"),
            Person(name: "James Wilson"),
            Person(name: "Sarah Chen", phone: "555-0204", email: "sarah@email.com"),
            Person(name: "David Kim"),
            Person(name: "Emma Thompson", phone: "555-0306"),
        ]
        people.forEach { context.insert($0) }

        // Debts with varied states
        let calendar = Calendar.current
        let now = Date()

        let debts: [(String, Decimal, DebtDirection, Int, Int?, String?, DebtCategoryType)] = [
            ("Dinner at Nobu", 120.50, .owedToMe, 0, 14, nil, .food),
            ("Concert tickets", 85.00, .owedToMe, 1, 7, "Two tickets for the show", .personal),
            ("Rent share - Feb", 750.00, .iOwe, 2, -3, nil, .rent),
            ("Business supplies", 340.00, .owedToMe, 3, 30, "Office equipment", .business),
            ("Flight to NYC", 450.00, .iOwe, 4, 21, "Spring break trip", .travel),
            ("Textbooks", 200.00, .owedToMe, 1, nil, "Semester books", .education),
            ("Family dinner", 95.00, .iOwe, 5, -1, nil, .family),
            ("Gym membership", 60.00, .owedToMe, 0, 10, nil, .personal),
            ("Prescription meds", 180.00, .iOwe, 3, 5, nil, .medical),
            ("Grocery run", 67.30, .owedToMe, 2, nil, "Weekly groceries", .food),
            ("Uber rides", 42.00, .iOwe, 4, nil, nil, .travel),
            ("Birthday gift", 55.00, .owedToMe, 5, 3, "Group gift contribution", .personal),
        ]

        for (title, amount, direction, personIdx, dueDays, notes, catType) in debts {
            let dueDate = dueDays.map { calendar.date(byAdding: .day, value: $0, to: now) ?? now }
            let category = categories.first { $0.categoryType == catType }

            let debt = Debt(
                title: title,
                totalAmount: amount,
                direction: direction,
                person: people[personIdx],
                category: category,
                dueDate: dueDate,
                notes: notes
            )
            context.insert(debt)

            // Add some payments to certain debts
            if title == "Rent share - Feb" {
                let p1 = Payment(amount: 375.00, date: calendar.date(byAdding: .day, value: -5, to: now) ?? now, notes: "First half", debt: debt)
                context.insert(p1)
            } else if title == "Concert tickets" {
                let p1 = Payment(amount: 40.00, date: calendar.date(byAdding: .day, value: -2, to: now) ?? now, debt: debt)
                context.insert(p1)
            } else if title == "Grocery run" {
                let p1 = Payment(amount: 67.30, date: calendar.date(byAdding: .day, value: -1, to: now) ?? now, notes: "Paid in full", debt: debt)
                context.insert(p1)
            } else if title == "Family dinner" {
                let p1 = Payment(amount: 50.00, date: calendar.date(byAdding: .day, value: -3, to: now) ?? now, debt: debt)
                let p2 = Payment(amount: 45.00, date: now, notes: "Remaining balance", debt: debt)
                context.insert(p1)
                context.insert(p2)
            }
        }
    }

    static func clearAll(context: ModelContext) {
        do {
            try context.delete(model: Payment.self)
            try context.delete(model: Debt.self)
            try context.delete(model: Person.self)
            try context.delete(model: DebtCategory.self)
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
}
