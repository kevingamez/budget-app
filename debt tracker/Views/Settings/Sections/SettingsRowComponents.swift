import SwiftUI

/// Shared row + header primitives for the SettingsView sections.

struct SettingsSectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ColorTokens.textTertiary)
            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(ColorTokens.textTertiary)
                .textCase(.uppercase)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(ColorTokens.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ColorTokens.textTertiary)
        }
        .padding(14)
    }
}

/// Wraps a section's body content in the standard surface card.
struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(ColorTokens.surface)
            )
    }
}
