import Foundation
import UIKit
import Combine

/// 全局数据仓库：负责约会记录、纪念日、标签的读写与统计。
/// 所有数据 100% 存储在 App 沙盒（Documents），不联网、不上传。
final class AppStore: ObservableObject {
    static let shared = AppStore()

    @Published var records: [DateRecord] = [] {
        didSet { scheduleSave() }
    }
    @Published var anniversaries: [Anniversary] = [] {
        didSet { scheduleSave() }
    }
    /// 用户自定义标签（存储在 UserDefaults，预设标签见 presetTags）
    @Published var customTags: [String] = [] {
        didSet { saveCustomTags() }
    }

    private init() {
        load()
    }

    // MARK: - 标签
    /// 预设标签（固定，不可删）
    static let presetTags = ["美食探店", "看电影", "短途旅行", "居家约会", "散步逛街"]

    /// 全部可选标签 = 预设 + 自定义 + 记录里实际出现过的
    var allTags: [String] {
        var tags = Self.presetTags + customTags
        for t in records.flatMap(\.tags) where !tags.contains(t) {
            tags.append(t)
        }
        return tags
    }

    // MARK: - 存储路径
    var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var dataURL: URL {
        documentsURL.appendingPathComponent("data.json")
    }

    /// 照片目录：Documents/Photos
    var photosDirectory: URL {
        let url = documentsURL.appendingPathComponent("Photos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    private struct Snapshot: Codable {
        var records: [DateRecord]
        var anniversaries: [Anniversary]
    }

    // MARK: - 加载 / 保存
    private func load() {
        customTags = UserDefaults.standard.stringArray(forKey: "customTags") ?? []
        guard let data = try? Data(contentsOf: dataURL),
              let snap = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            return
        }
        records = snap.records
        anniversaries = snap.anniversaries
    }

    private var saveWorkItem: DispatchWorkItem?
    private func scheduleSave() {
        saveWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in self?.saveNow() }
        saveWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: item)
    }

    /// 立即把数据落盘到 data.json（原子写入，防止写一半丢数据）
    func saveNow() {
        let snap = Snapshot(records: records, anniversaries: anniversaries)
        if let data = try? JSONEncoder().encode(snap) {
            try? data.write(to: dataURL, options: .atomic)
        }
    }

    private func saveCustomTags() {
        UserDefaults.standard.set(customTags, forKey: "customTags")
    }

    // MARK: - 记录操作
    func add(_ record: DateRecord) {
        records.append(record)
        saveNow()
    }

    func update(_ record: DateRecord) {
        if let i = records.firstIndex(where: { $0.id == record.id }) {
            records[i] = record
            saveNow()
        }
    }

    func delete(_ record: DateRecord) {
        if let name = record.photoFilename {
            deletePhoto(named: name)
        }
        records.removeAll { $0.id == record.id }
        saveNow()
    }

    // MARK: - 照片读写
    /// 保存照片数据，返回文件名
    func savePhoto(_ data: Data, id: UUID) -> String? {
        let name = "\(id.uuidString).jpg"
        let url = photosDirectory.appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            return name
        } catch {
            return nil
        }
    }

    /// 用指定文件名写入照片（用于恢复备份）
    func writePhoto(_ data: Data, named name: String) {
        let url = photosDirectory.appendingPathComponent(name)
        try? data.write(to: url, options: .atomic)
    }

    func photoURL(named name: String?) -> URL? {
        guard let name = name else { return nil }
        let url = photosDirectory.appendingPathComponent(name)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    func loadPhoto(named name: String?) -> UIImage? {
        guard let url = photoURL(named: name) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    func deletePhoto(named name: String) {
        let url = photosDirectory.appendingPathComponent(name)
        try? FileManager.default.removeItem(at: url)
    }

    /// 当前照片目录下的所有文件名
    var allPhotoFiles: [String] {
        (try? FileManager.default.contentsOfDirectory(atPath: photosDirectory.path)) ?? []
    }

    // MARK: - 统计
    /// 总约会次数
    var totalCount: Int { records.count }

    /// 历史平均分（1...10）
    var averageRating: Double {
        guard !records.isEmpty else { return 0 }
        return Double(records.reduce(0) { $0 + $1.rating }) / Double(records.count)
    }

    /// 某月约会次数（默认本月）
    func monthCount(month: Date = .now) -> Int {
        let cal = Calendar.current
        return records.filter { cal.isDate($0.date, equalTo: month, toGranularity: .month) }.count
    }

    /// 某天的记录（按时间倒序）
    func records(on day: Date) -> [DateRecord] {
        let cal = Calendar.current
        return records
            .filter { cal.isDate($0.date, inSameDayAs: day) }
            .sorted { $0.date > $1.date }
    }

    /// 全部记录按时间倒序
    var sortedRecords: [DateRecord] {
        records.sorted { $0.date > $1.date }
    }

    /// 按标签筛选（nil 表示全部）
    func filtered(byTag tag: String?) -> [DateRecord] {
        guard let tag = tag else { return sortedRecords }
        return sortedRecords.filter { $0.tags.contains(tag) }
    }

    /// 打卡次数最多的地点排行
    func topLocations(limit: Int = 5) -> [LocationStat] {
        let counts = Dictionary(grouping: records.filter { !$0.location.isEmpty }, by: { $0.location })
            .mapValues { $0.count }
        return counts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { LocationStat(name: $0.key, count: $0.value) }
    }

    // MARK: - 纪念日
    /// 从纪念日到今天过了多少天（不足一天按 0 计）
    func daysSince(_ date: Date) -> Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let today = cal.startOfDay(for: Date())
        return max(cal.dateComponents([.day], from: start, to: today).day ?? 0, 0)
    }
}
