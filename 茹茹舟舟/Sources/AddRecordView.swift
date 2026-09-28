import SwiftUI
import UIKit
import PhotosUI

/// 打卡 / 编辑页：日期时间、封面照片、1-10 分打分、地点（定位或手输）、标签、备注
struct AddRecordView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    /// 传入记录则为编辑模式，否则为新增
    var record: DateRecord? = nil

    @State private var date: Date = .now
    @State private var location: String = ""
    @State private var rating: Int = 5
    @State private var note: String = ""
    @State private var tags: [String] = []

    // 照片相关状态
    @State private var photoImage: UIImage?          // 预览用
    @State private var pendingPhotoData: Data?       // 新选中的照片（尚未写入磁盘）
    @State private var photoItem: PhotosPickerItem?

    @StateObject private var locationService = LocationService()

    private enum Field { case location, note }
    @FocusState private var focusedField: Field?

    private var isEditing: Bool { record != nil }

    init(record: DateRecord? = nil) {
        self.record = record
        _date = State(initialValue: record?.date ?? .now)
        _location = State(initialValue: record?.location ?? "")
        _rating = State(initialValue: record?.rating ?? 5)
        _note = State(initialValue: record?.note ?? "")
        _tags = State(initialValue: record?.tags ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                dateSection
                photoSection
                ratingSection
                locationSection
                tagSection
                noteSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle(isEditing ? "编辑约会" : "记一次约会")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .font(.headline)
                }
            }
            .onAppear {
                // 编辑模式：把已有照片加载到预览
                if photoImage == nil, let name = record?.photoFilename {
                    photoImage = store.loadPhoto(named: name)
                }
            }
            .onChange(of: photoItem) { item in
                Task { await loadPhoto(item) }
            }
        }
    }

    // MARK: - 各分区
    private var dateSection: some View {
        Section("约会时间") {
            DatePicker("日期时间", selection: $date, displayedComponents: [.date, .hourAndMinute])
                .environment(\.locale, Locale(identifier: "zh_CN"))
        }
    }

    private var photoSection: some View {
        Section("封面照片（选一张）") {
            PhotosPicker(selection: $photoItem, matching: .images) {
                HStack(spacing: 12) {
                    if let img = photoImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        ZStack {
                            Theme.accent.opacity(0.5)
                            Image(systemName: "photo")
                                .foregroundColor(Theme.secondary)
                        }
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    Text(photoImage == nil ? "从相册选择一张照片" : "点击更换照片")
                        .font(Theme.rounded(15))
                        .foregroundColor(Theme.text)
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            if photoImage != nil {
                Button("移除照片", role: .destructive) {
                    photoImage = nil
                    pendingPhotoData = nil
                    photoItem = nil
                }
            }
        }
    }

    private var ratingSection: some View {
        Section("打分") {
            RatingSliderView(rating: $rating)
                .padding(.vertical, 8)
        }
    }

    private var locationSection: some View {
        Section("地点") {
            HStack {
                TextField("手动输入地点", text: $location)
                    .focused($focusedField, equals: .location)
                Button {
                    locationService.requestPlaceName { name in
                        if !name.isEmpty { location = name }
                    }
                } label: {
                    if locationService.isLoading {
                        ProgressView()
                    } else {
                        Label("定位", systemImage: "location.fill")
                            .font(Theme.rounded(14, weight: .medium))
                    }
                }
                .disabled(locationService.isLoading)
            }
        }
    }

    private var tagSection: some View {
        Section("标签") {
            TagPickerView(selected: $tags, allTags: store.allTags, customTags: $store.customTags)
        }
    }

    private var noteSection: some View {
        Section("备注") {
            TextEditor(text: $note)
                .frame(minHeight: 100)
                .focused($focusedField, equals: .note)
        }
    }

    // MARK: - 照片与保存
    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let img = UIImage(data: data) {
            // 压缩并缩放到合理尺寸，减小存储占用
            let processed = img.resizedData(maxDimension: 1600, quality: 0.82) ?? data
            pendingPhotoData = processed
            photoImage = UIImage(data: processed)
        }
        photoItem = nil // 清空选择，允许下次再选同一张照片
    }

    private func save() {
        let id = record?.id ?? UUID()
        var filename = record?.photoFilename

        if let data = pendingPhotoData {
            // 用户选了（或换了）新照片：删掉旧照片，写入新照片
            if let old = record?.photoFilename {
                store.deletePhoto(named: old)
            }
            filename = store.savePhoto(data, id: id)
        } else if photoImage == nil {
            // 没有照片（新增未选，或编辑时移除了）：删除磁盘上的旧照片
            if let old = record?.photoFilename {
                store.deletePhoto(named: old)
            }
            filename = nil
        }

        let newRecord = DateRecord(
            id: id,
            date: date,
            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
            rating: rating,
            note: note,
            photoFilename: filename,
            tags: tags
        )

        if isEditing {
            store.update(newRecord)
        } else {
            store.add(newRecord)
        }
        dismiss()
    }
}
