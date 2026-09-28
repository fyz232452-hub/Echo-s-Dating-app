import UIKit

extension UIImage {
    /// 缩放并压缩为 JPEG 数据：限制最长边、控制压缩质量，减小存储与备份体积。
    /// - Parameters:
    ///   - maxDimension: 最长边像素上限
    ///   - quality: JPEG 压缩质量 0...1
    func resizedData(maxDimension: CGFloat, quality: CGFloat) -> Data? {
        let maxSide = max(size.width, size.height)
        let scale: CGFloat = maxSide > maxDimension ? maxDimension / maxSide : 1.0
        let newSize = CGSize(width: max(1, size.width * scale), height: max(1, size.height * scale))
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
