import SwiftUI

@main
struct GlowMateApp: App {
    @StateObject private var model = GlowMateModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .preferredColorScheme(.light)
        }
    }
}
