import SwiftUI
import UIKit

/// 约会记录卡片：日期、地点、评分、照片缩略图、标签
struct RecordCardView: View {
    @EnvironmentObject var store: AppStore
    let record: DateRecord

    var body: some View {
        HStack(spacing: 14) {
            thumbnail
            info
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.secondary.opacity(0.5))
        }
        .padding(12)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    // 照片缩略图（无照片时显示占位）
    private var thumbnail: some View {
        Group {
            if let img = store.loadPhoto(named: record.photoFilename) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Theme.accent.opacity(0.5)
                    Text("💗").font(.system(size: 30))
                }
            }
        }
        .frame(width: 74, height: 74)
        .clipShape(RoundedRectangle(cornerRadius: Theme.smallCorner, style: .continuous))
    }

    // 文字信息
    private var info: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(dateText(record.date))
                .font(Theme.rounded(15, weight: .semibold))
                .foregroundColor(Theme.text)
                .lineLimit(1)

            if !record.location.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(record.location)
                        .lineLimit(1)
                }
                .font(Theme.rounded(13))
                .foregroundColor(Theme.secondary)
            }

            HStack(spacing: 5) {
                Text(ratingEmoji(record.rating))
                Text("\(record.rating) 分")
                    .font(Theme.rounded(13, weight: .medium))
                    .foregroundColor(Theme.text)
            }

            if !record.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(record.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(Theme.rounded(11))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.04))
                            .foregroundColor(Theme.secondary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}
