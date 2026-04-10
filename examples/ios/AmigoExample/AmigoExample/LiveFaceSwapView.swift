import SwiftUI
import PhotosUI
import AmigoFaceSwapSDK

struct LiveFaceSwapView: View {
    @State private var latent: FaceLatent?
    @State private var sourceImage: UIImage? = UIImage(named: "DefaultSourceFace")
    @State private var sourcePickerItem: PhotosPickerItem?
    @State private var isEnrolling = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Camera feed (full screen)
            if let latent {
                AmigoLiveCameraView(targetLatent: latent)
                    .ignoresSafeArea()
            } else {
                Color.black
                    .ignoresSafeArea()
                    .overlay {
                        if isEnrolling {
                            ProgressView("Loading face...")
                                .tint(.white)
                                .foregroundStyle(.white)
                        }
                    }
            }

            // Controls overlay
            VStack {
                Spacer()

                if let errorMessage {
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.red.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
                        .padding(.bottom, 8)
                }

                HStack(spacing: 16) {
                    // Source face thumbnail
                    if let sourceImage {
                        Image(uiImage: sourceImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }

                    // Pick a different face
                    PhotosPicker(selection: $sourcePickerItem, matching: .images) {
                        Label("Change Face", systemImage: "person.crop.circle.badge.plus")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                    }

                    if isEnrolling {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Live Face Swap")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await enrollFace(from: sourceImage) }
        .onChange(of: sourcePickerItem) { _ in
            loadAndEnroll(from: sourcePickerItem)
        }
    }

    private func enrollFace(from image: UIImage?) async {
        guard let image else { return }
        isEnrolling = true
        errorMessage = nil
        do {
            latent = try await AmigoFaceSwap.enrollFace(from: image)
        } catch {
            errorMessage = error.localizedDescription
        }
        isEnrolling = false
    }

    private func loadAndEnroll(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                sourceImage = image
                await enrollFace(from: image)
            }
        }
    }
}
