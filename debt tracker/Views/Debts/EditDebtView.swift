import SwiftUI
import SwiftData

private let S = AppStrings.shared

struct EditDebtView: View {
    @Bindable var debt: Debt
    @Environment(\.dismiss) private var dismiss
    @State private var hasDueDate: Bool
    @State private var dueDate: Date

    init(debt: Debt) {
        self.debt = debt
        self._hasDueDate = State(initialValue: debt.dueDate != nil)
        self._dueDate = State(initialValue: debt.dueDate ?? Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ColorTokens.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text(S.tr("addDebt.description"))
                                .font(AppTypography.footnote)
                                .foregroundStyle(ColorTokens.textSecondary)

                            TextField(S.tr("addDebt.placeholder"), text: $debt.title)
                                .font(AppTypography.body)
                                .foregroundStyle(ColorTokens.textPrimary)
                                .padding(12)
                                .background(ColorTokens.surfaceElevated, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
                        }

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text(S.tr("addDebt.category"))
                                .font(AppTypography.footnote)
                                .foregroundStyle(ColorTokens.textSecondary)

                            CategoryPickerView(selectedCategory: $debt.category)
                        }

                        // Due Date
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $hasDueDate.animation(AppAnimations.cardSpring)) {
                                Text(S.tr("addDebt.dueDate"))
                                    .font(AppTypography.body)
                                    .foregroundStyle(ColorTokens.textPrimary)
                            }
                            .tint(ColorTokens.primaryAccent)
                            .onChange(of: hasDueDate) { _, newValue in
                                debt.dueDate = newValue ? dueDate : nil
                            }

                            if hasDueDate {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundStyle(ColorTokens.primaryAccent)

                                    DatePicker("", selection: $dueDate, in: Date()..., displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(ColorTokens.primaryAccent)
                                        .onChange(of: dueDate) { _, newValue in
                                            debt.dueDate = newValue
                                        }

                                    Spacer()

                                    Text(dueDate.shortFormatted)
                                        .font(AppTypography.subheadline)
                                        .foregroundStyle(ColorTokens.textSecondary)
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(12)
                        .background(ColorTokens.surfaceElevated, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))

                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text(S.tr("addDebt.notes"))
                                .font(AppTypography.footnote)
                                .foregroundStyle(ColorTokens.textSecondary)

                            TextField(S.tr("addDebt.notesPlaceholder"), text: Binding(
                                get: { debt.notes ?? "" },
                                set: { debt.notes = $0.isEmpty ? nil : $0 }
                            ), axis: .vertical)
                                .font(AppTypography.body)
                                .foregroundStyle(ColorTokens.textPrimary)
                                .lineLimit(3...6)
                                .padding(12)
                                .background(ColorTokens.surfaceElevated, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
                        }
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(S.tr("editDebt.title"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(S.tr("common.done")) {
                        debt.updatedAt = Date()
                        dismiss()
                    }
                    .foregroundStyle(ColorTokens.primaryAccent)
                    .fontWeight(.semibold)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button(S.tr("common.cancel")) {
                        dismiss()
                    }
                    .foregroundStyle(ColorTokens.textSecondary)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
