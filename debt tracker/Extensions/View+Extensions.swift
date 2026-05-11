import SwiftUI

extension View {
    /// Applies a staggered fade/slide-in transition when the view is inserted.
    /// Content is visible by default — the animation runs once on first insert
    /// without gating visibility on a separate boolean. The per-item delay is
    /// capped to the first viewport so cells far down a long list don't wait
    /// seconds before appearing.
    func staggeredAppear(index: Int, appeared: Bool = true) -> some View {
        let effectiveIndex = min(max(index, 0), 8)
        let transition: AnyTransition = .opacity.combined(with: .offset(y: 20))
        return self.transition(transition.animation(AppAnimations.staggered(index: effectiveIndex)))
    }
}
