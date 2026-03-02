import UIKit

extension UIImage {
    func toBase64() -> String? {
        guard let data = self.jpegData(compressionQuality: 0.8) else { return nil }
        return data.base64EncodedString()
    }
}
