import SwiftUI

struct GradientCard<Content: View>: View {
    let gradient: LinearGradient
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(AppTheme.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(gradient)
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
            )
    }
}
