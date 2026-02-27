import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum ProfilePhotoStorage {
    private static let filename = "profile_photo.jpg"

    static var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(filename)
    }

    static func save(_ data: Data) {
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
                try? jpeg.write(to: fileURL)
                return
            }
        }
        #endif
        // Fallback: write raw data
        try? data.write(to: fileURL)
    }

    static func load() -> Data? {
        try? Data(contentsOf: fileURL)
    }

    static func delete() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
