import SwiftUI
import Foundation

// MARK: - 全局配色与字体
// 严格控制颜色数量：米白背景 / 奶杏·浅粉（同属浅色系）/ 深灰文字，共 3 个主色调。
enum Theme {
    /// 米白背景
    static let background = Color(red: 0.984, green: 0.973, blue: 0.953)
    /// 卡片白
    static let card = Color.white
    /// 奶杏主色
    static let accent = Color(red: 0.957, green: 0.886, blue: 0.800)
    /// 浅粉辅助色（用于爱心、小圆点等点缀）
    static let accent2 = Color(red: 0.965, green: 0.847, blue: 0.827)
    /// 深灰文字
    static let text = Color(red: 0.231, green: 0.220, blue: 0.208)
    /// 浅灰次级文字
    static let secondary = Color(red: 0.541, green: 0.522, blue: 0.494)

    /// 大圆角
    static let cornerRadius: CGFloat = 20
    /// 小圆角
    static let smallCorner: CGFloat = 14

    /// 系统圆润字体
    static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - 评分表情映射：1→5 由生气到平静，5→10 由平静到非常开心
func ratingEmoji(_ rating: Int) -> String {
    let emojis = ["😡", "😠", "🙁", "😕", "😐", "🙂", "😊", "😄", "😁", "😍"]
    let i = max(0, min(rating, 10) - 1)
    return emojis[i]
}

// MARK: - 日期格式化
enum Formatters {
    static let dateTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日 HH:mm"
        return f
    }()

    static let dateOnly: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日"
        return f
    }()

    static let monthTitle: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年 M月"
        return f
    }()
}

func dateText(_ date: Date) -> String { Formatters.dateTime.string(from: date) }
func dateOnlyText(_ date: Date) -> String { Formatters.dateOnly.string(from: date) }
