import SwiftUI

struct DebtPersonCard: View {
    let person: Person

    var body: some View {
        HStack(spacing: 14) {
            PersonAvatarView(person: person, size: .large)

            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(AppTypography.title3)
                    .foregroundStyle(ColorTokens.textPrimary)

                if let phone = person.phone {
                    Label(phone, systemImage: "phone.fill")
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.textSecondary)
                }
                if let email = person.email {
                    Label(email, systemImage: "envelope.fill")
                        .font(AppTypography.caption)
                        .foregroundStyle(ColorTokens.textSecondary)
                }
            }

            Spacer()
        }
        .cardStyle()
    }
}
