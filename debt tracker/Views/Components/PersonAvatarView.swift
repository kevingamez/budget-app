import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct PersonAvatarView: View {
    let person: Person?
    var size: AvatarSize = .medium

    enum AvatarSize {
        case small, medium, large

        var dimension: CGFloat {
            switch self {
            case .small: 32
            case .medium: 44
            case .large: 64
            }
        }

        var fontSize: Font {
            switch self {
            case .small: .system(size: 13, weight: .semibold, design: .rounded)
            case .medium: .system(size: 17, weight: .semibold, design: .rounded)
            case .large: .system(size: 24, weight: .semibold, design: .rounded)
            }
        }
    }

    private var initials: String {
        guard let name = person?.name, !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var body: some View {
        if let photoData = person?.photoData, let image = platformImage(from: photoData) {
            image
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
                .overlay(Circle().stroke(ColorTokens.surfaceBorder, lineWidth: 2))
        } else {
            ZStack {
                Circle()
                    .fill(ColorTokens.surfaceElevated)
                    .overlay(Circle().stroke(ColorTokens.surfaceBorder, lineWidth: 2))

                Text(initials)
                    .font(size.fontSize)
                    .foregroundStyle(ColorTokens.primaryAccent)
            }
            .frame(width: size.dimension, height: size.dimension)
        }
    }

    private func platformImage(from data: Data) -> Image? {
        #if canImport(UIKit)
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
        #elseif canImport(AppKit)
        guard let nsImage = NSImage(data: data) else { return nil }
        return Image(nsImage: nsImage)
        #else
        return nil
        #endif
    }
}
