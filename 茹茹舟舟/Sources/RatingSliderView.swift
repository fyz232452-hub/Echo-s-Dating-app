import SwiftUI
import UIKit

/// 1–10 分数字滑块：滑动时弹出对应表情，1→5 由生气到平静，5→10 由平静到非常开心。
/// 动效：表情切换带弹性缩放，滑块拖动带触觉反馈，柔和不突兀。
struct RatingSliderView: View {
    @Binding var rating: Int

    @State private var dragging = false

    var body: some View {
        VStack(spacing: 20) {
            // 表情：随分数变化 + 弹跳动效
            Text(ratingEmoji(rating))
                .font(.system(size: 68))
                .id(rating)
                .transition(.asymmetric(
                    insertion: .scale(scale: 1.4).combined(with: .opacity),
                    removal: .scale(scale: 0.5).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.32, dampingFraction: 0.6), value: rating)

            Text("\(rating) 分")
                .font(Theme.rounded(20, weight: .bold))
                .foregroundColor(Theme.text)
                .contentTransition(.numericText())

            // 滑块轨道
            GeometryReader { geo in
                let width = geo.size.width
                let step = width / 9.0
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.06))
                        .frame(height: 12)
                    Capsule()
                        .fill(Theme.accent)
                        .frame(width: max(step * CGFloat(rating - 1) + 6, 6), height: 12)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                        .offset(x: step * CGFloat(rating - 1))
                        .scaleEffect(dragging ? 1.15 : 1.0)
                }
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            dragging = true
                            let idx = Int(round(value.location.x / step)) + 1
                            let new = min(max(idx, 1), 10)
                            if new != rating {
                                rating = new
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                        .onEnded { _ in
                            dragging = false
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                )
            }
            .frame(height: 34)
            .padding(.horizontal, 6)

            // 刻度提示
            HStack {
                Text("不开心")
                Spacer()
                Text("平静")
                Spacer()
                Text("超开心")
            }
            .font(Theme.rounded(12))
            .foregroundColor(Theme.secondary)
            .padding(.horizontal, 4)
        }
    }
}
