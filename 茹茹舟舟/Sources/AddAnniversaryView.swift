import SwiftUI

/// 添加纪念日
struct AddAnniversaryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("纪念日名称") {
                    TextField("例如：在一起的日子", text: $name)
                }
                Section("日期") {
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "zh_CN"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("添加纪念日")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        store.anniversaries.append(Anniversary(name: n.isEmpty ? "纪念日" : n, date: date))
                        dismiss()
                    }
                }
            }
        }
    }
}
