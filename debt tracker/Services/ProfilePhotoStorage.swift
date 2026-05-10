import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum ProfilePhotoStorage {
    private static let filename = "profile_photo.jpg"
    private static let maxBytes = 10 * 1024 * 1024 // 10 MB

    static var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(filename)
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
                try? FileManager.default.setAttributes(
                    [.protectionKey: FileProtectionType.completeUnlessOpen],
                    ofItemAtPath: fileURL.path
                )
                return
            }
        }
        #endif
        // Fallback (and macOS path): write raw data.
        try data.write(to: fileURL)
        #if canImport(UIKit)
        try? FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.completeUnlessOpen],
            ofItemAtPath: fileURL.path
        )
        #endif
    }

    /// Non-throwing convenience used by existing call sites.
    /// Silently drops the write if size cap is exceeded or I/O fails.
    static func save(_ data: Data) {
        try? saveThrowing(data)
    }

    static func load() -> Data? {
        try? Data(contentsOf: fileURL)
    }

    static func delete() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
