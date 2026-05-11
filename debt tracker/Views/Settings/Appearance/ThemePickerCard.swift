import SwiftUI

/// Visual swatch card used inside the theme picker carousel.
struct ThemePickerCard: View {
    let palette: AppThemePalette
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                preview
                    .frame(width: 132, height: 84)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? palette.primaryAccent : Color.clear, lineWidth: 2)
                    )

                label
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppStrings.shared.tr(palette.nameKey))
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }

    private var preview: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(palette.background)

            VStack(alignment: .leading, spacing: 6) {
                titleBar
                accentRow
                RoundedRectangle(cornerRadius: 6)
                    .fill(palette.surfaceElevated)
                    .frame(height: 14)
            }
            .padding(8)
        }
    }

    private var titleBar: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(palette.surface)
            .frame(height: 18)
            .overlay(alignment: .leading) {
                HStack(spacing: 4) {
                    Circle().fill(palette.primaryGradient).frame(width: 8, height: 8)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(palette.textSecondary)
                        .frame(width: 36, height: 4)
                }
                .padding(.leading, 6)
            }
    }

    private var accentRow: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 6)
                .fill(palette.greenGradient)
                .frame(height: 22)
            RoundedRectangle(cornerRadius: 6)
                .fill(palette.redGradient)
                .frame(height: 22)
        }
    }

    private var label: some View {
        HStack(spacing: 6) {
            Text(AppStrings.shared.tr(palette.nameKey))
                .font(AppTypography.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(ColorTokens.textPrimary)
                .lineLimit(1)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(ColorTokens.primaryAccent)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 132, alignment: .leading)
    }
}
