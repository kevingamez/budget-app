import SwiftUI
import SwiftData

private let S = AppStrings.shared

struct ActivityFeedView: View {
    @Query(sort: \Payment.date, order: .reverse) private var allPayments: [Payment]
    @State private var viewModel = ActivityViewModel()
    @State private var appeared = false

    private var sections: [ActivityViewModel.ActivitySection] {
        viewModel.groupedPayments(from: allPayments)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ColorTokens.background.ignoresSafeArea()

                if allPayments.isEmpty {
                    EmptyStateView(
                        icon: "clock",
                        title: S.tr("activity.empty.title"),
                        subtitle: S.tr("activity.empty.subtitle")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 4) {
                            // Filter
                            directionFilter
                                .padding(.bottom, 8)

                            ForEach(Array(sections.enumerated()), id: \.element.id) { sectionIndex, section in
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(section.title)
                                        .font(AppTypography.footnote)
                                        .foregroundStyle(ColorTokens.textTertiary)
                                        .padding(.leading, 24)
                                        .padding(.bottom, 8)

                                    ForEach(Array(section.payments.enumerated()), id: \.element.id) { index, payment in
                                        ActivityRowView(
                                            payment: payment,
                                            isLast: index == section.payments.count - 1 && sectionIndex == sections.count - 1
                                        )
                                        .staggeredAppear(index: index, appeared: appeared)
                                    }
                                }
                                .padding(.bottom, 16)
                            }
                        }
                        .padding(.horizontal, AppTheme.screenPadding)
                        .padding(.bottom, 20)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle(S.tr("tab.activity"))
            .onAppear {
                withAnimation {
                    appeared = true
                }
            }
        }
    }

    private var directionFilter: some View {
        HStack(spacing: 8) {
            FilterChip(title: S.tr("filter.all"), isSelected: viewModel.filterDirection == nil) {
                withAnimation(AppAnimations.tabTransition) { viewModel.filterDirection = nil }
            }
            FilterChip(title: S.tr("filter.incoming"), isSelected: viewModel.filterDirection == .owedToMe) {
                withAnimation(AppAnimations.tabTransition) { viewModel.filterDirection = .owedToMe }
            }
            FilterChip(title: S.tr("filter.outgoing"), isSelected: viewModel.filterDirection == .iOwe) {
                withAnimation(AppAnimations.tabTransition) { viewModel.filterDirection = .iOwe }
            }
            Spacer()
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : ColorTokens.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected ? AnyShapeStyle(ColorTokens.primaryGradient) : AnyShapeStyle(ColorTokens.surfaceElevated),
                    in: Capsule()
                )
        }
    }
}
