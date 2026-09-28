import SwiftUI

/// 锁屏页：打开 App 时的面容 / 指纹验证
struct LockScreenView: View {
    var onUnlock: () -> Void

    @State private var message = "轻点解锁"

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("🔒")
                    .font(.system(size: 60))
                Text("茹茹舟舟")
                    .font(Theme.rounded(24, weight: .bold))
                    .foregroundColor(Theme.text)
                Text(message)
                    .font(Theme.rounded(14))
                    .foregroundColor(Theme.secondary)

                Button {
                    authenticate()
                } label: {
                    Label("使用面容 / 指纹解锁", systemImage: "faceid")
                        .font(Theme.rounded(16, weight: .semibold))
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Theme.accent)
                        .foregroundColor(Theme.text)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                .padding(.top, 12)
            }
        }
        .onAppear { authenticate() }
    }

    private func authenticate() {
        BiometricAuth.authenticate { ok in
            if ok {
                onUnlock()
            } else {
                message = "验证失败，请重试"
            }
        }
    }
}
