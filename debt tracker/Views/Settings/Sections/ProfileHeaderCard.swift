import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

private let S = AppStrings.shared

/// Tappable card at the top of Settings that opens ProfileSettingsView.
struct ProfileHeaderCard: View {
    let userName: String
    let profilePhotoData: Data?

    var body: some View {
        NavigationLink {
            ProfileSettingsView()
        } label: {
            VStack(spacing: 12) {
                avatar
                Text(userName.isEmpty ? S.tr("settings.setupProfile") : userName)
                    .font(AppTypography.title2)
                    .foregroundStyle(userName.isEmpty ? ColorTokens.textSecondary : ColorTokens.textPrimary)

                Text(userName.isEmpty ? S.tr("settings.tapToAddName") : S.tr("settings.tapToEditProfile"))
                    .font(AppTypography.caption)
                    .foregroundStyle(ColorTokens.textSecondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ColorTokens.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(ColorTokens.surface)
            )
        }
    }

    @ViewBuilder
    private var avatar: some View {
        ZStack {
            if let data = profilePhotoData, let image = platformImage(from: data) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(ColorTokens.primaryGradient)
                    .frame(width: 70, height: 70)

                Text(profileInitials)
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
            }
        }
    }

    private var profileInitials: String {
        let trimmed = userName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "?" }
        let parts = trimmed.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(trimmed.prefix(2)).uppercased()
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
