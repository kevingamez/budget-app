import SwiftUI

extension View {
    /// Applies a staggered fade/slide-in animation on appear.
    /// The per-item delay is capped to the first viewport (`index < 8`) so
    /// cells far down a long list don't wait seconds before appearing
    /// (or re-trigger long delays when scrolled into a LazyVStack later).
    func staggeredAppear(index: Int, appeared: Bool) -> some View {
        let effectiveIndex = min(max(index, 0), 8)
        return self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(AppAnimations.staggered(index: effectiveIndex), value: appeared)
    }
}
