import SwiftUI
import AmigoFaceSwapSDK

struct SetupView: View {
    @State private var isReady = false
    @State private var progress: Float = 0
    @State private var statusText = "Checking models…"
    @State private var errorMessage: String?

    var body: some View {
        if isReady {
            HomeView()
        } else {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "face.smiling")
                    .font(.system(size: 56))
                    .foregroundStyle(.blue)

                Text("Amigo SDK")
                    .font(.title.bold())

                VStack(spacing: 12) {
                    ProgressView(value: progress)
                        .frame(maxWidth: 240)

                    Text(statusText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Button("Retry") {
                        self.errorMessage = nil
                        Task { await setup() }
                    }
                    .buttonStyle(.borderedProminent)
                }

                Spacer()
            }
            .task { await setup() }
        }
    }

    @MainActor
    private func setup() async {
        do {
            statusText = "Downloading models…"
            try await AmigoFaceSwap.downloadModelsIfNeeded { downloadProgress in
                DispatchQueue.main.async {
                    self.progress = downloadProgress * 0.8
                }
            }

            statusText = "Initializing…"
            progress = 0.8
            try await AmigoFaceSwap.initialize(apiKey: "demo") { initProgress in
                DispatchQueue.main.async {
                    self.progress = 0.8 + initProgress * 0.2
                }
            }

            progress = 1.0
            statusText = "Ready"
            withAnimation { isReady = true }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
