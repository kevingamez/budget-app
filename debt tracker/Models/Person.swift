import Foundation
import SwiftData

@Model
final class Person {
    var id: UUID = UUID()
    var name: String = ""
    var phone: String?
    var email: String?

    @Attribute(.externalStorage)
    var photoData: Data?

    var createdAt: Date = Date()

    @Relationship(inverse: \Debt.person)
    var debts: [Debt] = []

    init(
        name: String,
        phone: String? = nil,
        email: String? = nil,
        photoData: Data? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.phone = phone
        self.email = email
        self.photoData = photoData
        self.createdAt = Date()
    }
}
