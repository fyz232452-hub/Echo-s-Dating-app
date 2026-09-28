import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// 备份文件结构：文字数据 + 照片（base64 编码），全部塞进一个 JSON 文件。
struct BackupPackage: Codable {
    var appName: String
    var exportedAt: Date
    var records: [DateRecord]
    var anniversaries: [Anniversary]
    /// 照片：文件名 -> base64 字符串
    var photos: [String: String]
}

enum BackupManager {
    static let filenameDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd-HHmm"
        return f
    }()

    /// 从当前数据仓库生成备份包
    static func makePackage(from store: AppStore) -> BackupPackage {
        var photos: [String: String] = [:]
        for name in store.allPhotoFiles {
            let url = store.photosDirectory.appendingPathComponent(name)
            if let data = try? Data(contentsOf: url) {
                photos[name] = data.base64EncodedString()
            }
        }
        return BackupPackage(
            appName: "茹茹舟舟",
            exportedAt: Date(),
            records: store.records,
            anniversaries: store.anniversaries,
            photos: photos
        )
    }

    /// 编码备份（使用 ISO8601 日期，便于阅读与跨版本恢复）
    static func encode(_ pkg: BackupPackage) throws -> Data {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        enc.dateEncodingStrategy = .iso8601
        return try enc.encode(pkg)
    }

    /// 解码备份文件
    static func decode(_ data: Data) throws -> BackupPackage {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return try dec.decode(BackupPackage.self, from: data)
    }

    /// 把备份内容写回 App（先恢复照片，再恢复数据）。返回恢复的记录数。
    @discardableResult
    static func restore(_ pkg: BackupPackage, into store: AppStore) -> Int {
        for (name, b64) in pkg.photos {
            if let data = Data(base64Encoded: b64) {
                store.writePhoto(data, named: name)
            }
        }
        store.records = pkg.records
        store.anniversaries = pkg.anniversaries
        store.saveNow()
        return pkg.records.count
    }
}

/// 用于 ShareLink 导出备份文件（可保存到系统"文件"App）
struct BackupDocument: Transferable {
    let data: Data
    let filename: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { doc in
            doc.data
        }
        .suggestedFileName { doc in doc.filename }
    }
}
