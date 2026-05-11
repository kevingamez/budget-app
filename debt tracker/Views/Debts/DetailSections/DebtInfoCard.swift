import SwiftUI

private let S = AppStrings.shared

struct DebtInfoCard: View {
    let debt: Debt

    var body: some View {
        VStack(spacing: 12) {
            infoRow(title: S.tr("detail.created"),
                    value: debt.createdAt.shortFormatted,
                    icon: "calendar")

            if let dueDate = debt.dueDate {
                infoRow(
                    title: S.tr("detail.dueDate"),
                    value: dueDate.shortFormatted,
                    icon: "clock.fill",
                    valueColor: debt.isOverdue ? ColorTokens.overdueColor : nil
                )
            }

            if let category = debt.category {
                infoRow(title: S.tr("detail.category"),
                        value: category.name,
                        icon: category.iconName)
            }

            if let notes = debt.notes, !notes.isEmpty {
                notesBlock(notes)
            }
        }
        .cardStyle()
    }

    private func infoRow(title: String, value: String, icon: String, valueColor: Color? = nil) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(AppTypography.subheadline)
                .foregroundStyle(ColorTokens.textTertiary)
            Spacer()
            Text(value)
                .font(AppTypography.subheadline)
                .foregroundStyle(valueColor ?? ColorTokens.textPrimary)
        }
    }

    private func notesBlock(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(S.tr("detail.notes"), systemImage: "note.text")
                .font(AppTypography.caption)
                .foregroundStyle(ColorTokens.textTertiary)
            Text(notes)
                .font(AppTypography.subheadline)
                .foregroundStyle(ColorTokens.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
