import SwiftUI
import SwiftData

private let S = AppStrings.shared

struct AddDebtView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Person.name) private var people: [Person]
    @State private var viewModel = AddDebtViewModel()
    @State private var showPersonPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                ColorTokens.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Amount
                        AmountTextField(text: $viewModel.amountString)
                            .padding(.top, 8)

                        // Direction
                        directionPicker

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

                        // Person
                        VStack(alignment: .leading, spacing: 8) {
                            Text(S.tr("addDebt.person"))
                                .font(AppTypography.footnote)
                                .foregroundStyle(ColorTokens.textSecondary)

                            if let person = viewModel.selectedPerson {
                                HStack {
                                    PersonAvatarView(person: person, size: .small)
                                    Text(person.name)
                                        .font(AppTypography.body)
                                        .foregroundStyle(ColorTokens.textPrimary)
                                    Spacer()
                                    Button {
                                        viewModel.selectedPerson = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(ColorTokens.textTertiary)
                                    }
                                }
                                .padding(12)
                                .background(ColorTokens.surfaceElevated, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
                            } else {
                                TextField(S.tr("addDebt.namePlaceholder"), text: $viewModel.newPersonName)
                                    .font(AppTypography.body)
                                    .foregroundStyle(ColorTokens.textPrimary)
                                    .padding(12)
                                    .background(ColorTokens.surfaceElevated, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))

                                if !people.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(people) { person in
                                                Button {
                                                    viewModel.selectedPerson = person
                                                    viewModel.newPersonName = ""
                                                } label: {
                                                    HStack(spacing: 6) {
                                                        PersonAvatarView(person: person, size: .small)
                                                        Text(person.name)
                                                            .font(AppTypography.caption)
                                                            .foregroundStyle(ColorTokens.textPrimary)
                                                    }
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 6)
                                                    .background(ColorTokens.surface, in: Capsule())
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text(S.tr("addDebt.category"))
                                .font(AppTypography.footnote)
                                .foregroundStyle(ColorTokens.textSecondary)

                            CategoryPickerView(selectedCategory: $viewModel.selectedCategory)
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

                        // Reminder
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $viewModel.reminderEnabled.animation(AppAnimations.cardSpring)) {
                                HStack(spacing: 8) {
                                    Image(systemName: "bell.fill")
                                        .foregroundStyle(ColorTokens.gold)
                                    Text(S.tr("addDebt.setReminder"))
                                        .font(AppTypography.body)
                                        .foregroundStyle(ColorTokens.textPrimary)
                                }
                            }
                            .tint(ColorTokens.primaryAccent)

                            if viewModel.reminderEnabled {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundStyle(ColorTokens.gold)

                                    DatePicker("", selection: $viewModel.reminderDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(ColorTokens.primaryAccent)

                                    Spacer()
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(12)
                        .background(ColorTokens.surfaceElevated, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))

                        // Save Button
                        Button {
                            viewModel.save(context: modelContext)
                            dismiss()
                        } label: {
                            Text(S.tr("addDebt.addDebt"))
                                .font(AppTypography.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    viewModel.isValid ? AnyShapeStyle(ColorTokens.primaryGradient) : AnyShapeStyle(ColorTokens.surfaceElevated),
                                    in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                )
                        }
                        .disabled(!viewModel.isValid)
                        .pressable()
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(S.tr("addDebt.title"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
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

    // MARK: - Direction Picker

    private var directionPicker: some View {
        HStack(spacing: 12) {
            DirectionOption(
                title: S.tr("direction.someoneOwesMe"),
                icon: "arrow.down.left",
                isSelected: viewModel.direction == .owedToMe,
                color: ColorTokens.green
            ) {
                withAnimation(AppAnimations.cardSpring) {
                    viewModel.direction = .owedToMe
                }
            }

            DirectionOption(
                title: S.tr("direction.iOweSomeone"),
                icon: "arrow.up.right",
                isSelected: viewModel.direction == .iOwe,
                color: ColorTokens.red
            ) {
                withAnimation(AppAnimations.cardSpring) {
                    viewModel.direction = .iOwe
                }
            }
        }
    }
}

// MARK: - Direction Option

private struct DirectionOption: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                Text(title)
                    .font(AppTypography.caption)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(isSelected ? color : ColorTokens.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(isSelected ? color.opacity(0.15) : ColorTokens.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .pressable()
    }
}
