import SwiftUI
import UIKit

/// 详情页：高清大图、完整备注、评分、地点、标签；支持编辑与删除
struct RecordDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let record: DateRecord

    @State private var showEdit = false
    @State private var showDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                bigPhoto
                ratingCard
                infoCard
                noteCard
            }
            .padding(16)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(dateOnlyText(record.date))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showEdit = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            AddRecordView(record: record)
        }
        .confirmationDialog(
            "确定删除这条记录吗？照片也会一起删除",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("删除", role: .destructive) {
                store.delete(record)
                dismiss()
            }
            Button("取消", role: .cancel) {}
        }
    }

    // 高清大图
    @ViewBuilder
    private var bigPhoto: some View {
        if let img = store.loadPhoto(named: record.photoFilename) {
            Image(uiImage: img)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        }
    }

    // 评分卡片
    private var ratingCard: some View {
        VStack(spacing: 8) {
            Text(ratingEmoji(record.rating))
                .font(.system(size: 52))
            Text("\(record.rating) 分")
                .font(Theme.rounded(18, weight: .bold))
                .foregroundColor(Theme.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Theme.accent.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }

    // 信息卡片
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            infoRow(icon: "calendar", text: dateText(record.date))
            if !record.location.isEmpty {
                infoRow(icon: "mappin.and.ellipse", text: record.location)
            }
            if !record.tags.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "tag")
                        .frame(width: 20)
                        .foregroundColor(Theme.secondary)
                    FlowLayout(spacing: 8) {
                        ForEach(record.tags, id: \.self) { tag in
                            Text(tag)
                                .font(Theme.rounded(12))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.black.opacity(0.04))
                                .foregroundColor(Theme.secondary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    // 备注卡片
    @ViewBuilder
    private var noteCard: some View {
        if !record.note.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("备注")
                    .font(Theme.rounded(14, weight: .semibold))
                    .foregroundColor(Theme.secondary)
                Text(record.note)
                    .font(Theme.rounded(15))
                    .foregroundColor(Theme.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(4)
            }
            .cardStyle()
        }
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(Theme.secondary)
            Text(text)
                .font(Theme.rounded(15))
                .foregroundColor(Theme.text)
        }
    }
}
