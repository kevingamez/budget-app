import Foundation

private let S = AppStrings.shared

@Observable
final class ActivityViewModel {
    var filterDirection: DebtDirection?

    struct ActivitySection: Identifiable {
        let id: String
        let title: String
        let payments: [Payment]
    }

    func groupedPayments(from payments: [Payment]) -> [ActivitySection] {
        let filtered: [Payment]
        if let direction = filterDirection {
            filtered = payments.filter { $0.debt?.direction == direction }
        } else {
            filtered = payments
        }

        let sorted = filtered.sorted { $0.date > $1.date }

        var sections: [String: [Payment]] = [:]
        var sectionOrder: [String] = []

        for payment in sorted {
            let key: String
            if payment.date.isToday {
                key = S.tr("activity.today")
            } else if payment.date.isYesterday {
                key = S.tr("activity.yesterday")
            } else if payment.date.isThisWeek {
                key = S.tr("activity.thisWeek")
            } else if payment.date.isThisMonth {
                key = S.tr("activity.thisMonth")
            } else {
                key = S.tr("activity.earlier")
            }

            if sections[key] == nil {
                sectionOrder.append(key)
            }
            sections[key, default: []].append(payment)
        }

        return sectionOrder.map { key in
            ActivitySection(id: key, title: key, payments: sections[key] ?? [])
        }
    }
}
