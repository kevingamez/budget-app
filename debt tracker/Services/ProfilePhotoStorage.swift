import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Profile photo lives in Application Support (not Documents) with `.complete`
/// file protection and an `isExcludedFromBackup` flag so it never lands in an
/// iCloud or iTunes backup.
enum ProfilePhotoStorage {
    private static let filename = "profile_photo.jpg"
    private static let maxBytes = 10 * 1024 * 1024 // 10 MB

    /// Application Support is created lazily on first read/write.
    static var fileURL: URL {
        let fm = FileManager.default
        let dir = (try? fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent(filename)
    }

    /// Throwing variant. Use this if you want to surface size-cap or I/O errors.
    static func saveThrowing(_ data: Data) throws {
        guard data.count <= maxBytes else {
            throw NSError(
                domain: "ProfilePhoto",
                code: 413,
                userInfo: [NSLocalizedDescriptionKey: "image too large"]
            )
        }

        migrateFromDocumentsIfNeeded()

        #if canImport(UIKit)
        // Compress and resize to max 500x500
        if let image = UIImage(data: data) {
            let maxDimension: CGFloat = 500
            let size = image.size
            let scale: CGFloat
            if size.width > maxDimension || size.height > maxDimension {
                scale = min(maxDimension / size.width, maxDimension / size.height)
            } else {
                scale = 1.0
            }
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let resized = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
            if let jpeg = resized.jpegData(compressionQuality: 0.8) {
                try jpeg.write(to: fileURL)
                applyProtection(to: fileURL)
                return
            }
        }
        #endif
        // Fallback (and macOS path): write raw data.
        try data.write(to: fileURL)
        applyProtection(to: fileURL)
    }

    /// Non-throwing convenience used by existing call sites.
    /// Silently drops the write if size cap is exceeded or I/O fails.
    static func save(_ data: Data) {
        try? saveThrowing(data)
    }

    static func load() -> Data? {
        migrateFromDocumentsIfNeeded()
        return try? Data(contentsOf: fileURL)
    }

    static func delete() {
        try? FileManager.default.removeItem(at: fileURL)
        // Also wipe the legacy Documents copy if it's still around.
        try? FileManager.default.removeItem(at: legacyDocumentsURL)
    }

    // MARK: - Internals

    private static var legacyDocumentsURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(filename)
    }

    /// Move a previously-saved photo out of `Documents/` (where it would get
    /// picked up by iCloud/iTunes backup) into Application Support.
    private static func migrateFromDocumentsIfNeeded() {
        let fm = FileManager.default
        let target = fileURL
        guard !fm.fileExists(atPath: target.path) else { return }
        let legacy = legacyDocumentsURL
        guard fm.fileExists(atPath: legacy.path) else { return }
        try? fm.moveItem(at: legacy, to: target)
        applyProtection(to: target)
    }

    private static func applyProtection(to url: URL) {
        #if canImport(UIKit)
        // `.complete`: file is encrypted whenever the device is locked. The
        // profile photo only renders inside Settings while the app is in the
        // foreground, so this stricter mode is safe.
        try? FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: url.path
        )
        #endif

        // Keep the photo out of iCloud / iTunes backups — it's purely local.
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        var mutableURL = url
        try? mutableURL.setResourceValues(resourceValues)
    }
}
