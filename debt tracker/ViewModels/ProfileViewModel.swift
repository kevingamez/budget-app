import Foundation
import PhotosUI
import SwiftUI

@Observable
final class ProfileViewModel {
    var name: String = ""
    var selectedPhotoItem: PhotosPickerItem?
    var profileImageData: Data?
    var isLoadingPhoto: Bool = false

    func loadExistingProfile() {
        name = UserDefaults.standard.string(forKey: "userName") ?? ""
        profileImageData = ProfilePhotoStorage.load()
    }

    func saveName() {
        UserDefaults.standard.set(name.trimmingCharacters(in: .whitespaces), forKey: "userName")
    }

    func loadPhoto(from item: PhotosPickerItem) async {
        isLoadingPhoto = true
        defer { isLoadingPhoto = false }

        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        ProfilePhotoStorage.save(data)
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
