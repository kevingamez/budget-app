import Foundation
import PhotosUI
import SwiftUI

@Observable
final class ProfileViewModel {
    var name: String = ""
    var selectedPhotoItem: PhotosPickerItem?
    var profileImageData: Data?
    var isLoadingPhoto: Bool = false
    /// Last photo error, surfaced to the view as a localized message. Cleared
    /// when the user successfully saves a new photo.
    var photoErrorMessage: String?

    func loadExistingProfile() {
        name = UserDefaults.standard.string(forKey: "userName") ?? ""
        profileImageData = ProfilePhotoStorage.load()
    }

    func saveName() {
        UserDefaults.standard.set(name.trimmingCharacters(in: .whitespaces), forKey: "userName")
    }

    func loadPhoto(from item: PhotosPickerItem) async {
        isLoadingPhoto = true
        photoErrorMessage = nil
        defer { isLoadingPhoto = false }

        let data: Data?
        do {
            data = try await item.loadTransferable(type: Data.self)
        } catch {
            photoErrorMessage = error.localizedDescription
            return
        }
        guard let data else {
            photoErrorMessage = AppStrings.shared.tr("profile.photoLoadFailed")
            return
        }
        do {
            try ProfilePhotoStorage.saveThrowing(data)
        } catch {
            // Surface the failure (size cap, full disk, protection class
            // rejection) instead of silently swallowing it like the old
            // `ProfilePhotoStorage.save(_:)` shortcut did.
            photoErrorMessage = error.localizedDescription
            return
        }
        profileImageData = ProfilePhotoStorage.load()
    }

    func removePhoto() {
        ProfilePhotoStorage.delete()
        profileImageData = nil
        selectedPhotoItem = nil
    }

    var hasPhoto: Bool {
        profileImageData != nil
    }

    var initials: String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "?" }
        let parts = trimmed.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(trimmed.prefix(2)).uppercased()
    }
}
