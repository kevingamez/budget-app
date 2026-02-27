import SwiftUI
import SwiftData

private let S = AppStrings.shared

struct DebtsListView: View {
    @Query(sort: \Debt.createdAt, order: .reverse) private var allDebts: [Debt]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DebtsListViewModel()
    @State private var appeared = false

    private var filteredDebts: [Debt] {
        viewModel.filteredDebts(from: allDebts)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ColorTokens.background.ignoresSafeArea()

                if allDebts.isEmpty {
                    EmptyStateView(
                        icon: "dollarsign.circle",
                        title: S.tr("debts.empty.title"),
                        subtitle: S.tr("debts.empty.subtitle"),
                        actionTitle: S.tr("addDebt.addDebt")
                    ) {
                        viewModel.showAddDebt = true
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Filter Picker
                            directionPicker

                            if filteredDebts.isEmpty {
                                EmptyStateView(
                                    icon: "magnifyingglass",
                                    title: S.tr("debts.noResults.title"),
                                    subtitle: S.tr("debts.noResults.subtitle")
                                )
                                .frame(height: 300)
                            } else {
                                ForEach(Array(filteredDebts.enumerated()), id: \.element.id) { index, debt in
                                    NavigationLink(value: debt) {
                                        DebtRowView(debt: debt)
                                            .staggeredAppear(index: index, appeared: appeared)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        contextMenuItems(for: debt)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                viewModel.deleteDebt(debt, context: modelContext)
                                            }
                                        } label: {
                                            Label(S.tr("common.delete"), systemImage: "trash")
                                        }

                                        if debt.derivedStatus != .paidOff && debt.derivedStatus != .forgiven {
                                            Button {
                                                withAnimation {
                                                    viewModel.markAsPaid(debt, context: modelContext)
                                                }
                                            } label: {
                                                Label(S.tr("status.paid"), systemImage: "checkmark.circle")
                                            }
                                            .tint(ColorTokens.green)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.screenPadding)
                        .padding(.bottom, 80)
                    }
                    .scrollIndicators(.hidden)
                }

                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            viewModel.showAddDebt = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 60, height: 60)
                                .background(ColorTokens.primaryGradient, in: Circle())
                                .shadow(color: ColorTokens.primaryAccent.opacity(0.4), radius: 12, y: 6)
                        }
                        .pressable()
                        .padding(.trailing, AppTheme.screenPadding)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle(S.tr("tab.debts"))
            .searchable(text: $viewModel.searchText, prompt: S.tr("debts.searchPrompt"))
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    sortMenu
                }
            }
            .navigationDestination(for: Debt.self) { debt in
                DebtDetailView(debt: debt)
            }
            .sheet(isPresented: $viewModel.showAddDebt) {
                AddDebtView()
            }
            .onAppear {
                withAnimation {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Direction Picker

    private var directionPicker: some View {
        HStack(spacing: 0) {
            FilterButton(title: S.tr("filter.all"), isSelected: viewModel.filterDirection == nil) {
                withAnimation(AppAnimations.tabTransition) {
                    viewModel.filterDirection = nil
                }
            }
            FilterButton(title: S.tr("filter.owedToMe"), isSelected: viewModel.filterDirection == .owedToMe) {
                withAnimation(AppAnimations.tabTransition) {
                    viewModel.filterDirection = .owedToMe
                }
            }
            FilterButton(title: S.tr("filter.iOwe"), isSelected: viewModel.filterDirection == .iOwe) {
                withAnimation(AppAnimations.tabTransition) {
                    viewModel.filterDirection = .iOwe
                }
            }
        }
        .background(ColorTokens.surfaceElevated, in: Capsule())
        .padding(.vertical, 4)
    }

    // MARK: - Sort Menu

    private var sortMenu: some View {
        Menu {
            ForEach(DebtSortOption.allCases) { option in
                Button {
                    viewModel.sortOption = option
                } label: {
                    HStack {
                        Text(option.label)
                        if viewModel.sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundStyle(ColorTokens.primaryAccent)
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func contextMenuItems(for debt: Debt) -> some View {
        if debt.derivedStatus != .paidOff && debt.derivedStatus != .forgiven {
            Button {
                withAnimation {
                    viewModel.markAsPaid(debt, context: modelContext)
                }
            } label: {
                Label(S.tr("common.markAsPaid"), systemImage: "checkmark.circle")
            }
        }

        Button(role: .destructive) {
            withAnimation {
                viewModel.deleteDebt(debt, context: modelContext)
            }
        } label: {
            Label(S.tr("common.delete"), systemImage: "trash")
        }
    }
}

// MARK: - Filter Button

private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.footnote)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : ColorTokens.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    isSelected ? AnyShapeStyle(ColorTokens.primaryGradient) : AnyShapeStyle(Color.clear),
                    in: Capsule()
                )
        }
    }
}
