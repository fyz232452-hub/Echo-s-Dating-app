import SwiftUI

/// 日历页：月历标记有约会的日期，点日期查看当天记录
struct CalendarView: View {
    @EnvironmentObject var store: AppStore
    @State private var currentMonth: Date = .now
    @State private var selectedDate: Date? = nil

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
    private let weekdaySymbols = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    monthCard
                    if let date = selectedDate {
                        DayRecordsSection(date: date)
                    } else {
                        EmptyStateView(icon: "📅", title: "点一个日期", subtitle: "看看那天你们去了哪里")
                    }
                }
                .padding(16)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("日历")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // 月卡片
    private var monthCard: some View {
        VStack(spacing: 12) {
            HStack {
                Button { changeMonth(-1) } label: {
                    Image(systemName: "chevron.left").font(.system(size: 15, weight: .semibold))
                }
                Spacer()
                Text(Formatters.monthTitle.string(from: currentMonth))
                    .font(Theme.rounded(17, weight: .bold))
                Spacer()
                Button { changeMonth(1) } label: {
                    Image(systemName: "chevron.right").font(.system(size: 15, weight: .semibold))
                }
            }
            .foregroundColor(Theme.text)

            HStack {
                ForEach(weekdaySymbols, id: \.self) { s in
                    Text(s)
                        .font(Theme.rounded(12, weight: .semibold))
                        .foregroundColor(Theme.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(Array(monthDays.enumerated()), id: \.offset) { _, day in
                    DayCell(date: day, selectedDate: $selectedDate)
                }
            }
        }
        .cardStyle()
    }

    /// 本月要显示的日期数组（前面补 nil 占位，周一起始）
    private var monthDays: [Date?] {
        let cal = Calendar.current
        let start = cal.dateInterval(of: .month, for: currentMonth)!.start
        let dayCount = cal.range(of: .day, in: .month, for: currentMonth)!.count
        let firstWeekday = cal.component(.weekday, from: start) // 1=周日...7=周六
        let leading = (firstWeekday + 5) % 7 // 周一起始的空白数
        var arr: [Date?] = Array(repeating: nil, count: leading)
        for i in 0..<dayCount {
            arr.append(cal.date(byAdding: .day, value: i, to: start))
        }
        return arr
    }

    private func changeMonth(_ delta: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: delta, to: currentMonth) ?? currentMonth
        }
    }
}

// 单个日期格子
private struct DayCell: View {
    @EnvironmentObject var store: AppStore
    let date: Date?
    @Binding var selectedDate: Date?

    var body: some View {
        Group {
            if let date = date {
                let hasRecord = !store.records(on: date).isEmpty
                let isToday = Calendar.current.isDateInToday(date)
                let isSelected: Bool = {
                    guard let sel = selectedDate else { return false }
                    return Calendar.current.isDate(sel, inSameDayAs: date)
                }()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedDate = date
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(Theme.rounded(15, weight: isToday ? .bold : .regular))
                            .foregroundColor(isSelected ? .white : Theme.text)
                            .frame(width: 32, height: 32)
                            .background(isSelected ? Theme.text : Color.clear)
                            .clipShape(Circle())
                        Circle()
                            .fill(hasRecord ? Theme.accent2 : Color.clear)
                            .frame(width: 6, height: 6)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear.frame(height: 44)
            }
        }
    }
}

// 选中日期的记录列表
private struct DayRecordsSection: View {
    @EnvironmentObject var store: AppStore
    let date: Date

    var body: some View {
        let records = store.records(on: date)
        VStack(alignment: .leading, spacing: 12) {
            Text("\(dateOnlyText(date)) 的约会")
                .font(Theme.rounded(15, weight: .semibold))
                .foregroundColor(Theme.secondary)
            if records.isEmpty {
                EmptyStateView(icon: "🫧", title: "这一天没有约会", subtitle: "去记一笔吧")
            } else {
                ForEach(records) { record in
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
