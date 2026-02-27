import Foundation

private let S = AppStrings.shared

// MARK: - Debt Direction

enum DebtDirection: String, Codable, CaseIterable, Identifiable {
    case owedToMe = "owedToMe"
    case iOwe = "iOwe"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .owedToMe: S.tr("direction.owedToMe")
        case .iOwe: S.tr("direction.iOwe")
        }
    }

    var shortLabel: String {
        switch self {
        case .owedToMe: S.tr("direction.incoming")
        case .iOwe: S.tr("direction.outgoing")
        }
    }
}

// MARK: - Debt Status

enum DebtStatus: String, Codable, CaseIterable, Identifiable {
    case active
    case partiallyPaid
    case paidOff
    case overdue
    case forgiven

    var id: String { rawValue }

    var label: String {
        switch self {
        case .active: S.tr("status.active")
        case .partiallyPaid: S.tr("status.partiallyPaid")
        case .paidOff: S.tr("status.paidOff")
        case .overdue: S.tr("status.overdue")
        case .forgiven: S.tr("status.forgiven")
        }
    }
}

// MARK: - Debt Category Type

enum DebtCategoryType: String, Codable, CaseIterable, Identifiable {
    case personal
    case business
    case family
    case rent
    case food
    case travel
    case medical
    case education
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .personal: S.tr("category.personal")
        case .business: S.tr("category.business")
        case .family: S.tr("category.family")
        case .rent: S.tr("category.rent")
        case .food: S.tr("category.food")
        case .travel: S.tr("category.travel")
        case .medical: S.tr("category.medical")
        case .education: S.tr("category.education")
        case .other: S.tr("category.other")
        }
    }

    var defaultIcon: String {
        switch self {
        case .personal: "person.fill"
        case .business: "briefcase.fill"
        case .family: "house.fill"
        case .rent: "building.2.fill"
        case .food: "fork.knife"
        case .travel: "airplane"
        case .medical: "cross.case.fill"
        case .education: "graduationcap.fill"
        case .other: "ellipsis.circle.fill"
        }
    }

    var defaultColorHex: String {
        switch self {
        case .personal: "#7C5CFC"
        case .business: "#3B82F6"
        case .family: "#F59E0B"
        case .rent: "#EF4444"
        case .food: "#10B981"
        case .travel: "#06B6D4"
        case .medical: "#EC4899"
        case .education: "#8B5CF6"
        case .other: "#6B7280"
        }
    }
}
