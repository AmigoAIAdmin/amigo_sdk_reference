import SwiftUI
import AmigoFaceSwapSDK

struct SetupView: View {
    @State private var isReady = false
    @State private var progress: Float = 0
    @State private var statusText = "Initializing…"
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
        let apiKey = Secrets.amigoAPIKey
        guard !apiKey.isEmpty, apiKey != "your-api-key-here" else {
            errorMessage = "Set your API key in Secrets.swift"
            return
        }

        do {
            statusText = "Initializing…"
            try await AmigoFaceSwap.initialize(
                apiKey: apiKey
            ) { downloadProgress in
                DispatchQueue.main.async {
                    self.statusText = "Downloading models…"
                    self.progress = downloadProgress * 0.9
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
