import SwiftUI
import PhotosUI
import AmigoFaceSwapSDK

struct FaceSwapView: View {
    @State private var sourceImage: UIImage? = UIImage(named: "DefaultSourceFace")
    @State private var targetImage: UIImage? = UIImage(named: "DefaultTargetImage")
    @State private var resultImage: UIImage?
    @State private var isProcessing = false
    @State private var errorMessage: String?

    @State private var sourcePickerItem: PhotosPickerItem?
    @State private var targetPickerItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Source face
                ImageSection(
                    title: "Source Face",
                    subtitle: "The face identity to apply",
                    image: sourceImage,
                    pickerItem: $sourcePickerItem
                )

                // Target image
                ImageSection(
                    title: "Target Image",
                    subtitle: "The image whose face will be replaced",
                    image: targetImage,
                    pickerItem: $targetPickerItem
                )

                // Swap button
                Button {
                    Task { await performSwap() }
                } label: {
                    Group {
                        if isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Label("Swap Face", systemImage: "arrow.triangle.2.circlepath")
                        }
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSwap ? .blue : .gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!canSwap || isProcessing)
                .padding(.horizontal)

                // Error
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.callout)
                        .padding(.horizontal)
                }

                // Result
                if let resultImage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Result")
                            .font(.headline)
                            .padding(.horizontal)
                        Image(uiImage: resultImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Face Swap")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: sourcePickerItem) { _ in
            loadImage(from: sourcePickerItem) { sourceImage = $0 }
        }
        .onChange(of: targetPickerItem) { _ in
            loadImage(from: targetPickerItem) { targetImage = $0 }
        }
    }

    private var canSwap: Bool {
        sourceImage != nil && targetImage != nil
    }

    private func performSwap() async {
        guard let source = sourceImage, let target = targetImage else { return }
        isProcessing = true
        errorMessage = nil
        resultImage = nil

        do {
            let latent = try await AmigoFaceSwap.enrollFace(from: source)
            let result = try await AmigoFaceSwap.swapFace(in: target, using: latent)
            resultImage = result
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }

    private func loadImage(from item: PhotosPickerItem?, completion: @escaping (UIImage?) -> Void) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                completion(image)
            }
        }
    }
}

// MARK: - Image Section

private struct ImageSection: View {
    let title: String
    let subtitle: String
    let image: UIImage?
    @Binding var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Text(image == nil ? "Select" : "Change")
                        .font(.subheadline.weight(.medium))
                }
            }
            .padding(.horizontal)

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                    .frame(height: 150)
                    .overlay {
                        Text("No image selected")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
            }
        }
    }
}
