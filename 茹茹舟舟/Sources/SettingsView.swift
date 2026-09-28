import SwiftUI
import UniformTypeIdentifiers

/// 设置页：隐私解锁、纪念日、标签管理、数据备份/恢复、地点排行、关于
struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @AppStorage("isLockEnabled") private var isLockEnabled = true

    @State private var showAddAnniversary = false
    @State private var showImport = false
    @State private var importMessage: String?
    @State private var backupDocument: BackupDocument?

    var body: some View {
        NavigationStack {
            List {
                privacySection
                anniversarySection
                tagManageSection
                backupSection
                rankingSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddAnniversary) {
                AddAnniversaryView()
            }
            .fileImporter(isPresented: $showImport, allowedContentTypes: [.json]) { result in
                handleImport(result)
            }
            .alert("导入结果", isPresented: Binding(
                get: { importMessage != nil },
                set: { if !$0 { importMessage = nil } }
            )) {
                Button("好", role: .cancel) {}
            } message: {
                Text(importMessage ?? "")
            }
        }
    }

    // MARK: - 隐私
    private var privacySection: some View {
        Section {
            Toggle(isOn: $isLockEnabled) {
                Label("面容 / 指纹解锁", systemImage: "faceid")
            }
        } header: {
            Text("隐私")
        } footer: {
            Text("开启后，每次打开 App 都需要验证面容 / 指纹（或锁屏密码）。")
        }
    }

    // MARK: - 纪念日
    private var anniversarySection: some View {
        Section {
            ForEach(store.anniversaries) { anni in
                HStack {
                    Text("💗")
                    VStack(alignment: .leading, spacing: 2) {
                        Text(anni.name)
                            .font(Theme.rounded(15, weight: .medium))
                        Text("第 \(store.daysSince(anni.date)) 天")
                            .font(Theme.rounded(12))
                            .foregroundColor(Theme.secondary)
                    }
                    Spacer()
                    Text(dateOnlyText(anni.date))
                        .font(Theme.rounded(12))
                        .foregroundColor(Theme.secondary)
                }
            }
            .onDelete { idx in
                store.anniversaries.remove(atOffsets: idx)
            }
            Button {
                showAddAnniversary = true
            } label: {
                Label("添加纪念日", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("纪念日")
        }
    }

    // MARK: - 标签管理
    private var tagManageSection: some View {
        Section {
            ForEach(store.allTags, id: \.self) { tag in
                HStack {
                    Text(tag)
                    Spacer()
                    if store.customTags.contains(tag) {
                        Button {
                            store.customTags.removeAll { $0 == tag }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Theme.secondary)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("预设")
                            .font(Theme.rounded(11))
                            .foregroundColor(Theme.secondary)
                    }
                }
            }
            HStack {
                TextField("添加自定义标签", text: $newTagField)
                Button("添加") { addCustomTag() }
                    .disabled(newTagField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        } header: {
            Text("标签管理")
        } footer: {
            Text("预设标签固定；自定义标签可随时删除（已用到记录上的标签不会丢失）。")
        }
    }

    @State private var newTagField = ""

    private func addCustomTag() {
        let t = newTagField.trimmingCharacters(in: .whitespacesAndNewlines)
        if !t.isEmpty, !store.customTags.contains(t), !AppStore.presetTags.contains(t) {
            store.customTags.append(t)
        }
        newTagField = ""
    }

    // MARK: - 数据备份
    private var backupSection: some View {
        Section {
            Button {
                backupDocument = makeBackupDocument()
            } label: {
                Label("生成备份文件", systemImage: "doc.badge.plus")
            }
            if let doc = backupDocument {
                ShareLink(item: doc, preview: SharePreview("茹茹舟舟备份")) {
                    Label("导出备份（含照片）", systemImage: "square.and.arrow.up")
                }
            }
            Button {
                showImport = true
            } label: {
                Label("从备份恢复", systemImage: "square.and.arrow.down")
            }
        } header: {
            Text("数据备份")
        } footer: {
            Text("备份文件包含全部记录与照片，可保存到“文件”App。恢复会覆盖当前数据。")
        }
    }

    // MARK: - 地点排行
    private var rankingSection: some View {
        Section("最常去的约会地点") {
            let tops = store.topLocations()
            if tops.isEmpty {
                Text("还没有记录")
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(tops.enumerated()), id: \.offset) { i, item in
                    HStack {
                        Text(rankEmoji(i))
                        Text(item.name)
                        Spacer()
                        Text("\(item.count) 次")
                            .foregroundColor(Theme.secondary)
                    }
                }
            }
        }
    }

    // MARK: - 关于
    private var aboutSection: some View {
        Section("关于") {
            HStack {
                Text("版本")
                Spacer()
                Text("1.0.0").foregroundColor(.secondary)
            }
        }
    }

    // MARK: - 工具方法
    private func makeBackupDocument() -> BackupDocument {
        let pkg = BackupManager.makePackage(from: store)
        let data = (try? BackupManager.encode(pkg)) ?? Data()
        let name = "茹茹舟舟备份_\(BackupManager.filenameDateFormatter.string(from: Date())).json"
        return BackupDocument(data: data, filename: name)
    }

    private func handleImport(_ result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let ok = url.startAccessingSecurityScopedResource()
            defer { if ok { url.stopAccessingSecurityScopedResource() } }
            let data = try Data(contentsOf: url)
            let pkg = try BackupManager.decode(data)
            let count = BackupManager.restore(pkg, into: store)
            importMessage = "已恢复 \(count) 条约会记录"
        } catch {
            importMessage = "导入失败：\(error.localizedDescription)"
        }
    }

    private func rankEmoji(_ index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "💗"
        }
    }
}
