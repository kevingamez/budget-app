import SwiftUI

private let S = AppStrings.shared

struct DefaultDirectionSection: View {
    @Binding var defaultDirection: String

    var body: some View {
        Group {
            directionButton(
                value: "owedToMe",
                title: S.tr("direction.someoneOwesMe"),
                icon: "arrow.down.left",
                tint: ColorTokens.green
            )
            directionButton(
                value: "iOwe",
                title: S.tr("direction.iOweSomeone"),
                icon: "arrow.up.right",
                tint: ColorTokens.red
            )
        }
    }

    private func directionButton(value: String, title: String, icon: String, tint: Color) -> some View {
        Button {
            withAnimation(AppAnimations.cardSpring) {
                defaultDirection = value
            }
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                    .frame(width: 24)
                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(ColorTokens.textPrimary)
                Spacer()
                if defaultDirection == value {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(tint)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
