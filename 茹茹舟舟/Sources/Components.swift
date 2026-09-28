import SwiftUI

// MARK: - 圆角卡片背景
struct CardBackground: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

extension View {
    /// 统一的圆角卡片样式
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardBackground(padding: padding))
    }
}

// MARK: - 流式标签布局（基于 iOS 16 Layout 协议）
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - 标签胶囊
struct TagChip: View {
    let text: String
    var selected: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            Text(text)
                .font(Theme.rounded(13, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(selected ? Theme.accent : Color.black.opacity(0.04))
                .foregroundColor(Theme.text)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(Theme.rounded(26, weight: .bold))
                .foregroundColor(Theme.text)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(title)
                .font(Theme.rounded(12))
                .foregroundColor(Theme.secondary)
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(Theme.rounded(11))
                    .foregroundColor(Theme.secondary.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 6)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

// MARK: - 空状态
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 48))
            Text(title)
                .font(Theme.rounded(17, weight: .semibold))
                .foregroundColor(Theme.text)
            Text(subtitle)
                .font(Theme.rounded(13))
                .foregroundColor(Theme.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
    }
}
