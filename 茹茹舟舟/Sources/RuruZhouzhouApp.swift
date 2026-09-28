import SwiftUI

@main
struct RuruZhouzhouApp: App {
    @StateObject private var store = AppStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
