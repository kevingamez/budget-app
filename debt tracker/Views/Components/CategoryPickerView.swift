import SwiftUI
import SwiftData

struct CategoryPickerView: View {
    @Binding var selectedCategory: DebtCategory?
    @Query(sort: \DebtCategory.name) private var categories: [DebtCategory]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory?.id == category.id
                    ) {
                        withAnimation(AppAnimations.cardSpring) {
                            if selectedCategory?.id == category.id {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

private struct CategoryChip: View {
    let category: DebtCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.system(size: 12))

                Text(category.name)
                    .font(AppTypography.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color(hex: category.colorHex).opacity(0.3) : ColorTokens.surfaceElevated)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color(hex: category.colorHex) : ColorTokens.surfaceBorder, lineWidth: 1)
            )
            .foregroundStyle(isSelected ? Color(hex: category.colorHex) : ColorTokens.textSecondary)
        }
        .pressable()
    }
}
