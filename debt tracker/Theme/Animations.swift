import SwiftUI

enum AppAnimations {
    // Card appear/disappear
    static let cardSpring = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.3)

    // Progress bar fill
    static let progressFill = Animation.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.2)

    // Tab switching
    static let tabTransition = Animation.spring(response: 0.35, dampingFraction: 0.85)

    // Sheet presentation
    static let sheetSpring = Animation.spring(response: 0.4, dampingFraction: 0.82)

    // Button press scale
    static let buttonPress = Animation.spring(response: 0.25, dampingFraction: 0.6)

    // Staggered list items
    static let listItemAppear = Animation.spring(response: 0.45, dampingFraction: 0.8)

    // Number counting
    static let countUp = Animation.easeOut(duration: 0.6)

    // Subtle pulse for attention
    static let pulse = Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)

    // Stagger delay per item
    static func staggered(index: Int) -> Animation {
        listItemAppear.delay(Double(index) * 0.05)
    }
}
