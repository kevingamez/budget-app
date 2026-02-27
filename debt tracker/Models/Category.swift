import Foundation
import SwiftData

@Model
final class DebtCategory {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String = "#7C5CFC"
    var iconName: String = "ellipsis.circle.fill"
    var categoryType: DebtCategoryType = DebtCategoryType.other
    var createdAt: Date = Date()

    @Relationship(inverse: \Debt.category)
    var debts: [Debt] = []

    init(
        name: String,
        colorHex: String,
        iconName: String,
        categoryType: DebtCategoryType
    ) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.categoryType = categoryType
        self.createdAt = Date()
    }

    convenience init(from type: DebtCategoryType) {
        self.init(
            name: type.label,
            colorHex: type.defaultColorHex,
            iconName: type.defaultIcon,
            categoryType: type
        )
    }
}
