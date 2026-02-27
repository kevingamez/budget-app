import SwiftUI

extension View {
    func staggeredAppear(index: Int, appeared: Bool) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(AppAnimations.staggered(index: index), value: appeared)
    }
}
