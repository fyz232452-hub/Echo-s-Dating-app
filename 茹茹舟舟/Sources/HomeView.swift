import SwiftUI

/// 首页：顶部统计 + 纪念日 + 标签筛选 + 约会记录列表，右下角悬浮打卡按钮
struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTag: String? = nil
    @State private var showAdd = false

    private var filteredRecords: [DateRecord] {
        store.filtered(byTag: selectedTag)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 16) {
                        statsHeader
                        anniversaryStrip
                        tagFilter
                        recordsList
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 96)
                }

                // 悬浮打卡按钮
                Button {
                    showAdd = true
                } label: {
                    Label("记一次约会", systemImage: "plus")
                        .font(Theme.rounded(16, weight: .semibold))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 16)
                        .background(Theme.accent)
                        .foregroundColor(Theme.text)
                        .clipShape(Capsule())
                        .shadow(color: Theme.accent.opacity(0.7), radius: 10, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("茹茹舟舟")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAdd) {
                AddRecordView()
            }
        }
    }

    // MARK: - 统计卡片
    private var statsHeader: some View {
        HStack(spacing: 12) {
            StatCard(title: "总约会", value: "\(store.totalCount)", subtitle: "次")
            StatCard(title: "本月", value: "\(store.monthCount())", subtitle: "次")
            StatCard(title: "平均分", value: String(format: "%.1f", store.averageRating), subtitle: "满分 10")
        }
    }

    // MARK: - 纪念日横条
    @ViewBuilder
    private var anniversaryStrip: some View {
        if !store.anniversaries.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(store.anniversaries) { anni in
                        VStack(spacing: 4) {
                            Text("💗")
                                .font(.system(size: 22))
                            Text(anni.name)
                                .font(Theme.rounded(13, weight: .semibold))
                                .foregroundColor(Theme.text)
                            Text("第 \(store.daysSince(anni.date)) 天")
                                .font(Theme.rounded(12))
                                .foregroundColor(Theme.secondary)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Theme.accent2.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.smallCorner, style: .continuous))
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - 标签筛选
    private var tagFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                TagChip(text: "全部", selected: selectedTag == nil) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedTag = nil }
                }
                ForEach(store.allTags, id: \.self) { tag in
                    TagChip(text: tag, selected: selectedTag == tag) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTag = (selectedTag == tag) ? nil : tag
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - 记录列表
    @ViewBuilder
    private var recordsList: some View {
        if filteredRecords.isEmpty {
            EmptyStateView(
                icon: "🥰",
                title: "还没有约会记录",
                subtitle: "点右下角的“记一次约会”，把你们的第一次约会留下来吧"
            )
        } else {
            VStack(spacing: 12) {
                ForEach(filteredRecords) { record in
                    NavigationLink {
                        RecordDetailView(record: record)
                    } label: {
                        RecordCardView(record: record)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
