import Foundation

/// 一条约会记录
struct DateRecord: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    /// 约会日期与时间
    var date: Date
    /// 地点
    var location: String
    /// 打分（1...10）
    var rating: Int
    /// 备注
    var note: String
    /// 封面照片文件名（存放在 Documents/Photos 下，nil 表示没有照片）
    var photoFilename: String?
    /// 标签
    var tags: [String]

    init(
        id: UUID = UUID(),
        date: Date = .now,
        location: String = "",
        rating: Int = 5,
        note: String = "",
        photoFilename: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.date = date
        self.location = location
        self.rating = rating
        self.note = note
        self.photoFilename = photoFilename
        self.tags = tags
    }
}

/// 一个纪念日
struct Anniversary: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    /// 纪念日名称，例如"在一起的日子"
    var name: String
    /// 纪念日日期
    var date: Date
}

/// 地点排行条目
struct LocationStat: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
}
