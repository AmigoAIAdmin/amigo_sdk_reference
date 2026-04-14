# Amigo Face Swap SDK for iOS — Documentation

The Amigo Face Swap SDK enables on-device, real-time face swapping on iOS. All ML inference runs locally using CoreML and Metal — no images are sent to the cloud.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
  - [AmigoFaceSwap](#amigofaceswap)
  - [FaceLatent](#facelatent)
  - [LipMode](#lipmode)
  - [AmigoError](#amigoerror)
  - [AmigoLiveCameraView (SwiftUI)](#amigolivecameraview-swiftui)
  - [AmigoLiveViewController (UIKit)](#amigoliveviewcontroller-uikit)
  - [AmigoLiveSession](#amigolivesession)
  - [AmigoLiveSessionDelegate](#amigolivesessiondelegate)
- [Usage Guides](#usage-guides)
  - [Static Image Face Swap](#static-image-face-swap)
  - [Real-Time Camera Face Swap](#real-time-camera-face-swap)
  - [Custom Pipeline (WebRTC / Video)](#custom-pipeline-webrtc--video)
  - [Background Replacement](#background-replacement)
  - [Pre-Computed Embeddings](#pre-computed-embeddings)
- [Billing](#billing)
- [Requirements](#requirements)

---

## Installation

Add the SDK via Swift Package Manager:

1. In Xcode, go to **File → Add Package Dependencies**.
2. Enter the repository URL:
   ```
   https://github.com/AmigoAIAdmin/AmigoSDK_iOS.git
   ```
3. Select version **1.0.2** or later.
4. Add `AmigoFaceSwapSDK` to your target.

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AmigoAIAdmin/AmigoSDK_iOS.git", from: "1.0.2")
]
```

## Quick Start

```swift
import AmigoFaceSwapSDK

// 1. Initialize (downloads models on first run)
try await AmigoFaceSwap.initialize(apiKey: "your-api-key") { progress in
    print("Download: \(Int(progress * 100))%")
}

// 2. Enroll a source face
let latent = try await AmigoFaceSwap.enrollFace(from: sourcePhoto)

// 3a. Static image swap
let result = try await AmigoFaceSwap.swapFace(in: targetPhoto, using: latent)

// 3b. OR real-time camera swap (SwiftUI)
AmigoLiveCameraView(targetLatent: latent)
```

---

## API Reference

### AmigoFaceSwap

The main entry point. All methods are static — no instance needed.

#### `initialize(apiKey:onProgress:)`

```swift
public static func initialize(
    apiKey: String,
    onProgress: ((Float) -> Void)? = nil
) async throws
```

Initialize the SDK and create a billable session. Must be called before any other SDK method.

| Parameter | Type | Description |
|---|---|---|
| `apiKey` | `String` | Your API key from [sdk.amigoai.io/dashboard](https://sdk.amigoai.io/dashboard) |
| `onProgress` | `((Float) -> Void)?` | Download progress callback (0.0 → 1.0). Only called if models need downloading. |

**Throws:** `AmigoError.invalidAPIKey`, `.revokedAPIKey`, `.quotaExceeded`, `.serverError`, `.modelDownloadFailed`, `.modelDecryptionFailed`, `.modelLoadFailed`, `.networkRequired`

**Important:** Each call to `initialize` creates one billable session. Do not call it repeatedly — call once at app launch, then use the SDK freely.

---

#### `enrollFace(from:)`

```swift
public static func enrollFace(from image: UIImage) async throws -> FaceLatent
```

Extract a face embedding from a photo. The image should contain one clearly visible, forward-facing face.

| Parameter | Type | Description |
|---|---|---|
| `image` | `UIImage` | Photo containing the source face |

**Returns:** A `FaceLatent` that can be reused across multiple swaps.

**Throws:** `AmigoError.noFaceDetected`, `.notInitialized`

---

#### `swapFace(in:using:lipMode:)`

```swift
public static func swapFace(
    in inputImage: UIImage,
    using latent: FaceLatent,
    lipMode: LipMode = .innerLips
) async throws -> UIImage
```

Swap the face in `inputImage` with the identity encoded in `latent`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `inputImage` | `UIImage` | — | The image whose face will be replaced |
| `latent` | `FaceLatent` | — | Source face identity from `enrollFace(from:)` |
| `lipMode` | `LipMode` | `.innerLips` | Lip blending mode |

**Returns:** A `UIImage` with the face swapped.

**Throws:** `AmigoError.noFaceDetected`, `.notInitialized`

---

#### `processFrame(_:using:lipMode:)`

```swift
public static func processFrame(
    _ pixelBuffer: CVPixelBuffer,
    using latent: FaceLatent,
    lipMode: LipMode = .innerLips
) throws -> CIImage?
```

Process a single video frame synchronously. Designed for custom pipelines — WebRTC, video playback, screen recording, etc.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `pixelBuffer` | `CVPixelBuffer` | — | The video frame to process |
| `latent` | `FaceLatent` | — | Source face identity |
| `lipMode` | `LipMode` | `.innerLips` | Lip blending mode |

**Returns:** A `CIImage` with the face swapped, or `nil` if no face was detected (render the original frame in that case).

**Threading:** Call from a serial background queue. Synchronous and optimized for sustained 30 fps.

---

#### `clearModelCache()`

```swift
public static func clearModelCache()
```

Delete all cached models, forcing a re-download on next `initialize()`. Useful for debugging or if models appear corrupted.

---

### FaceLatent

A 512-dimensional face embedding representing a face identity. Value type, `Sendable`, and `Hashable`.

```swift
public struct FaceLatent: Sendable, Hashable {
    public init?(embedding: [Float])    // From Float array (512 elements)
    public init?(embedding: [Double])   // From Double array (512 elements)
}
```

- Returned by `enrollFace(from:)` for on-device enrollment.
- Construct directly from a pre-computed 512-dim embedding (e.g., from your server).
- Cache and reuse freely — switching between pre-enrolled latents has zero latency.

---

### LipMode

Controls how lips are blended during face swap.

```swift
public enum LipMode: Int, Sendable {
    case none       // Use source face lips as-is
    case outerLips  // Blend outer lip region from target
    case innerLips  // Blend inner lip region (default, most natural)
}
```

---

### AmigoError

All errors thrown by the SDK.

| Case | Description |
|---|---|
| `.notInitialized` | `initialize(apiKey:)` was not called |
| `.invalidAPIKey(String)` | API key is invalid or expired |
| `.revokedAPIKey` | API key was revoked in the dashboard |
| `.quotaExceeded(limit:used:)` | Monthly session quota exceeded |
| `.noFaceDetected` | No face found in the image |
| `.modelLoadFailed` | CoreML model failed to load |
| `.modelDownloadFailed(String)` | CDN download error |
| `.modelDecryptionFailed` | Model decryption/extraction failed |
| `.networkRequired` | No cached models and no network |
| `.serverError(String)` | Backend HTTP error |
| `.inferenceFailure(String)` | Unexpected inference result |
| `.invalidInput(String)` | Invalid image or data |

All cases conform to `LocalizedError` with human-readable `errorDescription`.

---

### AmigoLiveCameraView (SwiftUI)

A drop-in SwiftUI view that displays a live face-swapped camera feed.

```swift
public struct AmigoLiveCameraView: UIViewRepresentable {
    public init(
        targetLatent: FaceLatent,
        lipMode: LipMode = .innerLips,
        cameraPosition: AVCaptureDevice.Position = .front,
        onFrame: ((UIImage) -> Void)? = nil
    )
}
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `targetLatent` | `FaceLatent` | — | Face identity to swap onto the feed |
| `lipMode` | `LipMode` | `.innerLips` | Lip blending mode |
| `cameraPosition` | `.front` / `.back` | `.front` | Camera to use |
| `onFrame` | `((UIImage) -> Void)?` | `nil` | Receive each processed frame (main thread) |

**Example:**

```swift
struct ContentView: View {
    let latent: FaceLatent

    var body: some View {
        AmigoLiveCameraView(targetLatent: latent)
            .ignoresSafeArea()
    }
}
```

**Recording frames:**

```swift
AmigoLiveCameraView(targetLatent: latent) { frame in
    myRecorder.append(frame)
}
```

---

### AmigoLiveViewController (UIKit)

A ready-to-use view controller for UIKit apps.

```swift
public final class AmigoLiveViewController: UIViewController {
    public let session: AmigoLiveSession
    public var onFrame: ((UIImage) -> Void)?

    public init(
        targetLatent: FaceLatent,
        lipMode: LipMode = .innerLips,
        cameraPosition: AVCaptureDevice.Position = .front
    )
}
```

**Example:**

```swift
let vc = AmigoLiveViewController(targetLatent: latent)
present(vc, animated: true)
```

Access `vc.session` to change settings at runtime (lip mode, target face, background image, etc.).

---

### AmigoLiveSession

The underlying camera session powering both `AmigoLiveCameraView` and `AmigoLiveViewController`. Use directly when you need full control over the camera lifecycle.

```swift
public final class AmigoLiveSession: NSObject {
    public let previewView: UIView
    public var targetLatent: FaceLatent       // Switch faces at runtime
    public var lipMode: LipMode               // Default: .innerLips
    public var isFaceSwapEnabled: Bool        // Default: true
    public var backgroundImage: UIImage?      // nil to disable
    public weak var delegate: AmigoLiveSessionDelegate?

    public init(targetLatent: FaceLatent,
                cameraPosition: AVCaptureDevice.Position = .front)

    public func start()           // Request camera permission and begin
    public func stop()            // Stop capture and release camera
    public func switchCamera()    // Toggle front ↔ back
}
```

**Example:**

```swift
let session = AmigoLiveSession(targetLatent: latent)
session.delegate = self
view.addSubview(session.previewView)
session.previewView.frame = view.bounds
session.start()

// Switch face at runtime — zero latency
session.targetLatent = anotherLatent
```

---

### AmigoLiveSessionDelegate

```swift
public protocol AmigoLiveSessionDelegate: AnyObject {
    func session(_ session: AmigoLiveSession, didOutput frame: UIImage)
    func session(_ session: AmigoLiveSession, didEncounterError error: Error)  // optional
}
```

Both callbacks are invoked on the **main thread**.

---

## Usage Guides

### Static Image Face Swap

```swift
import AmigoFaceSwapSDK

// Initialize once at app launch
try await AmigoFaceSwap.initialize(apiKey: "ak_live_...")

// Enroll source face (cache this for reuse)
let latent = try await AmigoFaceSwap.enrollFace(from: sourcePhoto)

// Swap face in target image
let result = try await AmigoFaceSwap.swapFace(in: targetPhoto, using: latent)
imageView.image = result
```

### Real-Time Camera Face Swap

**SwiftUI:**

```swift
import AmigoFaceSwapSDK

struct LiveView: View {
    @State private var latent: FaceLatent?

    var body: some View {
        Group {
            if let latent {
                AmigoLiveCameraView(targetLatent: latent)
                    .ignoresSafeArea()
            } else {
                ProgressView("Loading...")
            }
        }
        .task {
            try? await AmigoFaceSwap.initialize(apiKey: "ak_live_...")
            latent = try? await AmigoFaceSwap.enrollFace(from: sourcePhoto)
        }
    }
}
```

**UIKit:**

```swift
import AmigoFaceSwapSDK

class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            try await AmigoFaceSwap.initialize(apiKey: "ak_live_...")
            let latent = try await AmigoFaceSwap.enrollFace(from: sourcePhoto)
            let vc = AmigoLiveViewController(targetLatent: latent)
            present(vc, animated: true)
        }
    }
}
```

### Custom Pipeline (WebRTC / Video)

Use `processFrame(_:using:)` for frame-by-frame processing in your own pipeline:

```swift
// In your AVCaptureVideoDataOutputSampleBufferDelegate or WebRTC callback:
func processVideoFrame(_ pixelBuffer: CVPixelBuffer) {
    if let swapped = try? AmigoFaceSwap.processFrame(pixelBuffer, using: latent) {
        // Render swapped CIImage to your display layer or encoder
        renderCIImage(swapped)
    } else {
        // No face detected — render original frame
        renderPixelBuffer(pixelBuffer)
    }
}
```

### Background Replacement

Replace the background behind the detected person during live sessions:

```swift
let session = AmigoLiveSession(targetLatent: latent)
session.backgroundImage = UIImage(named: "office-background")
session.start()

// Disable background replacement
session.backgroundImage = nil
```

Background replacement uses Vision person segmentation and works with the front camera.

### Pre-Computed Embeddings

If you compute face embeddings server-side, skip on-device enrollment:

```swift
// From your API response
let embedding: [Float] = serverResponse.faceEmbedding  // 512 floats

if let latent = FaceLatent(embedding: embedding) {
    let result = try await AmigoFaceSwap.swapFace(in: targetPhoto, using: latent)
}
```

---

## Billing

- Each call to `AmigoFaceSwap.initialize(apiKey:)` creates **one billable session**.
- After initialization, all subsequent API calls (`enrollFace`, `swapFace`, `processFrame`, live camera) are **free** — no per-frame or per-image charges.
- Model downloads only occur when the model version changes. Cached models are reused automatically.
- Monitor usage at [sdk.amigoai.io/dashboard](https://sdk.amigoai.io/dashboard).

## Requirements

| Requirement | Minimum |
|---|---|
| iOS | 16.0+ |
| Swift | 5.9+ |
| Xcode | 15.0+ |
| Architecture | arm64 (device), arm64 + x86_64 (simulator) |

The SDK uses CoreML with Metal acceleration. All inference runs on-device — no images leave the user's phone.
