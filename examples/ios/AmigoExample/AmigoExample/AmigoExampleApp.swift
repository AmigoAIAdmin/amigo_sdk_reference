import SwiftUI
import AmigoFaceSwapSDK

@main
struct AmigoExampleApp: App {
    init() {
        Task {
            try? await AmigoFaceSwap.initialize(apiKey: "demo")
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
