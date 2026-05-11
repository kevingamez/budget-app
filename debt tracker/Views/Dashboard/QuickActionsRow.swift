import SwiftUI

/// Circular tinted icon-buttons with labels — Revolut's "Add money / Transfer / Pay"
/// row sits directly under the hero balance.
struct QuickActionsRow: View {
    let actions: [QuickAction]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(actions) { action in
                Button(action: action.action) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(ColorTokens.surface)
                                .overlay(Circle().stroke(ColorTokens.surfaceBorder, lineWidth: 0.5))
                            Image(systemName: action.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(ColorTokens.primaryAccent)
                        }
                        .frame(width: 52, height: 52)

                        Text(action.label)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(ColorTokens.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .pressable()
                #if os(iOS)
                .hoverEffect(.lift)
                #endif
            }
        }
    }
}

struct QuickAction: Identifiable {
    let id = UUID()
    let label: String
    let icon: String
    let action: () -> Void
}
