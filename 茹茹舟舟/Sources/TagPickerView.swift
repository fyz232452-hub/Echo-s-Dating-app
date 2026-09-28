import SwiftUI

/// 标签选择器：预设 + 自定义，支持多选、支持现场新增自定义标签
struct TagPickerView: View {
    @Binding var selected: [String]
    let allTags: [String]
    @Binding var customTags: [String]

    @State private var newTag = ""
    @State private var showAddField = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FlowLayout(spacing: 8) {
                ForEach(allTags, id: \.self) { tag in
                    TagChip(text: tag, selected: selected.contains(tag)) {
                        toggle(tag)
                    }
                }
                Button {
                    showAddField = true
                } label: {
                    Label("自定义", systemImage: "plus")
                        .font(Theme.rounded(13, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Theme.accent2.opacity(0.6))
                        .foregroundColor(Theme.text)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            if showAddField {
                HStack(spacing: 8) {
                    TextField("输入新标签", text: $newTag)
                        .textFieldStyle(.roundedBorder)
                    Button("添加") {
                        let t = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !t.isEmpty, !allTags.contains(t) {
                            customTags.append(t)
                            selected.append(t)
                        }
                        newTag = ""
                        showAddField = false
                    }
                    .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func toggle(_ tag: String) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            if let i = selected.firstIndex(of: tag) {
                selected.remove(at: i)
            } else {
                selected.append(tag)
            }
        }
    }
}
