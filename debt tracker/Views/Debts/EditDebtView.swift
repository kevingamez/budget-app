import SwiftUI
import SwiftData

private let S = AppStrings.shared

struct EditDebtView: View {
    let debt: Debt
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: EditDebtViewModel

    init(debt: Debt) {
        self.debt = debt
        self._viewModel = State(initialValue: EditDebtViewModel(debt: debt))
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

                            TextField(S.tr("addDebt.placeholder"), text: $viewModel.title)
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

                            CategoryPickerView(selectedCategory: $viewModel.category)
                        }

                        // Due Date
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $viewModel.hasDueDate.animation(AppAnimations.cardSpring)) {
                                Text(S.tr("addDebt.dueDate"))
                                    .font(AppTypography.body)
                                    .foregroundStyle(ColorTokens.textPrimary)
                            }
                            .tint(ColorTokens.primaryAccent)

                            if viewModel.hasDueDate {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundStyle(ColorTokens.primaryAccent)

                                    DatePicker("", selection: $viewModel.dueDate, in: Date()..., displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(ColorTokens.primaryAccent)

                                    Spacer()

                                    Text(viewModel.dueDate.shortFormatted)
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

                            TextField(S.tr("addDebt.notesPlaceholder"), text: $viewModel.notes, axis: .vertical)
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
                        viewModel.save(context: modelContext)
                        dismiss()
                    }
                    .foregroundStyle(ColorTokens.primaryAccent)
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isValid)
                    .keyboardShortcut(.defaultAction)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button(S.tr("common.cancel")) {
                        dismiss()
                    }
                    .foregroundStyle(ColorTokens.textSecondary)
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
