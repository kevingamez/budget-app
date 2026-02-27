import SwiftUI

struct AnimatedProgressBar: View {
    let progress: Double
    var gradient: LinearGradient = ColorTokens.primaryGradient
    var height: CGFloat = 8
    var trackColor: Color = ColorTokens.surfaceElevated

    @State private var animatedProgress: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(trackColor)
                    .frame(height: height)

                Capsule()
                    .fill(gradient)
                    .frame(width: max(0, geo.size.width * min(animatedProgress, 1.0)), height: height)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(AppAnimations.progressFill) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(AppAnimations.progressFill) {
                animatedProgress = newValue
            }
        }
    }
}
