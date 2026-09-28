import SwiftUI

/// 根视图：三栏 Tab + 锁屏覆盖
struct ContentView: View {
    @AppStorage("isLockEnabled") private var isLockEnabled = true
    @Environment(\.scenePhase) private var scenePhase
    @State private var isLocked = false

    var body: some View {
        MainTabView()
            .fullScreenCover(isPresented: $isLocked) {
                LockScreenView { isLocked = false }
                    .interactiveDismissDisabled()
            }
            .onAppear { lockIfNeeded() }
            .onChange(of: scenePhase) { phase in
                // 退到后台或进入非活跃状态时，自动上锁
                if phase == .background || phase == .inactive {
                    isLocked = isLockEnabled
                }
            }
    }

    private func lockIfNeeded() {
        if isLockEnabled {
            isLocked = true
        }
    }
}

/// 三栏主界面：约会 / 日历 / 设置
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("约会", systemImage: "heart.fill") }
            CalendarView()
                .tabItem { Label("日历", systemImage: "calendar") }
            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape.fill") }
        }
        .tint(Theme.text)
    }
}
