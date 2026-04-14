# Amigo Face Swap SDK

**On-device, real-time face swap for iOS and Android.**

Amigo is a production-grade face swap SDK that runs entirely on-device. No server round-trips, no cloud processing, no privacy concerns. Drop it into your app and ship real-time face swap in minutes.

[![Platform](https://img.shields.io/badge/platform-iOS%2016%2B%20%7C%20Android%20API%2026%2B-blue)](#platform-support)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)](#ios-sdk)
[![Kotlin](https://img.shields.io/badge/Kotlin-1.9%2B-purple)](#android-sdk)
[![License](https://img.shields.io/badge/license-Commercial-green)](#license)

---

## Why Amigo?

| | Amigo SDK | Cloud-based alternatives |
|---|---|---|
| **Latency** | Real-time (30 fps on-device) | 2–10s per image (network round-trip) |
| **Privacy** | Images never leave the device | Images uploaded to third-party servers |
| **Offline** | Works without internet (after initial setup) | Requires constant connectivity |
| **Cost** | Per-session billing, unlimited frames | Per-image or per-minute billing |
| **Quality** | 512×512 CoreML / 256×256 TFLite neural pipeline | Varies |

## Features

- **Real-time face swap** — 30 fps live camera processing with CoreML (iOS) and TFLite (Android)
- **Static image face swap** — High-quality single-image processing
- **On-device ML inference** — Zero network latency, complete user privacy
- **Face enrollment** — Extract reusable 512-dim face embeddings from any photo
- **Lip blending modes** — Natural lip sync with configurable blending (none, outer, inner)
- **Background replacement** — Real-time person segmentation with custom backgrounds
- **SwiftUI & Jetpack Compose** — Native UI components for modern app architectures
- **UIKit & Android Views** — Full support for traditional UI frameworks
- **Per-frame API** — Direct `CVPixelBuffer` / `Bitmap` processing for WebRTC, video playback, and custom pipelines
- **Encrypted model delivery** — AES-encrypted models downloaded from CDN, cached locally
- **Hot-swappable faces** — Switch between enrolled face identities at runtime with zero latency

## Platform Support

| Platform | ML Runtime | Input Resolution | UI Components |
|---|---|---|---|
| **iOS 16+** | CoreML + Metal | 512×512 | SwiftUI, UIKit |
| **Android API 26+** | TensorFlow Lite + GPU | 256×256 | Jetpack Compose, Android Views |

---

## Quick Start — iOS

### Install via Swift Package Manager

```
https://github.com/AmigoAIAdmin/AmigoSDK_iOS.git
```

### 3-Line Integration (SwiftUI)

```swift
import AmigoFaceSwapSDK

// 1. Initialize
try await AmigoFaceSwap.initialize(apiKey: "your-api-key")

// 2. Enroll a face
let latent = try await AmigoFaceSwap.enrollFace(from: sourcePhoto)

// 3. Live camera face swap
AmigoLiveCameraView(targetLatent: latent)
```

### Static Image Swap

```swift
let latent = try await AmigoFaceSwap.enrollFace(from: sourcePhoto)
let result = try await AmigoFaceSwap.swapFace(in: targetPhoto, using: latent)
```

### UIKit

```swift
let latent = try await AmigoFaceSwap.enrollFace(from: sourcePhoto)
let vc = AmigoLiveViewController(targetLatent: latent)
present(vc, animated: true)
```

> **Full iOS documentation:** [SDK Documentation](documents/ios/SDK_DOCUMENTATION.md) · [Example App Runbook](examples/ios/README.md)

---

## Quick Start — Android

### Install via Gradle

```kotlin
// settings.gradle.kts
dependencyResolutionManagement {
    repositories {
        maven { url = uri("https://maven.amigoai.io/releases") }
    }
}

// build.gradle.kts
dependencies {
    implementation("ai.amigo:faceswap-sdk:1.0.0")
}
```

### Integration (Jetpack Compose)

```kotlin
import ai.amigo.sdk.AmigoFaceSwap
import ai.amigo.sdk.camera.AmigoLiveCameraView

// 1. Initialize
AmigoFaceSwap.initialize(context, apiKey = "your-api-key")

// 2. Enroll a face
val latent = AmigoFaceSwap.enrollFace(sourceBitmap)

// 3. Live camera face swap
AmigoLiveCameraView(targetLatent = latent)
```

### Static Image Swap

```kotlin
val latent = AmigoFaceSwap.enrollFace(sourceBitmap)
val result = AmigoFaceSwap.swapFace(targetBitmap, latent)
```

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  Your App                        │
│  ┌───────────────────────────────────────────┐  │
│  │           Amigo Face Swap SDK             │  │
│  │                                           │  │
│  │  ┌─────────┐  ┌──────────┐  ┌─────────┐  │  │
│  │  │  Face   │  │  Face    │  │  Live   │  │  │
│  │  │Enrollment│  │  Swap   │  │ Camera  │  │  │
│  │  │         │  │ Engine   │  │ Session │  │  │
│  │  └────┬────┘  └────┬─────┘  └────┬────┘  │  │
│  │       │            │              │       │  │
│  │  ┌────▼────────────▼──────────────▼────┐  │  │
│  │  │     CoreML / TFLite Runtime         │  │  │
│  │  │     (Metal GPU / GPU Delegate)      │  │  │
│  │  └────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

**Pipeline:** Face detection → Landmark extraction → Affine warp → Neural network inference → Inverse warp → Mask blend → Output

All processing happens on-device. The only network calls are API key validation (once per session) and model downloads (once, then cached).

---

## Examples

This repository contains fully working example apps:

| Platform | Location | Features |
|---|---|---|
| **iOS** | [`examples/ios/AmigoExample`](examples/ios/) | Static swap, live camera, photo picker |
| **Android** | [`examples/android/AmigoExample`](examples/android/) | Static swap, live camera, photo picker |

Each example includes step-by-step setup instructions. See the [iOS Runbook](examples/ios/README.md) to get started.

---

## API Overview

### iOS — `AmigoFaceSwap`

| Method | Description |
|---|---|
| `initialize(apiKey:onProgress:)` | Initialize SDK and download models |
| `enrollFace(from:)` | Extract face embedding from UIImage |
| `swapFace(in:using:lipMode:)` | Swap face in a static image |
| `processFrame(_:using:lipMode:)` | Process a single CVPixelBuffer (for custom pipelines) |
| `clearModelCache()` | Force re-download on next init |

### Android — `AmigoFaceSwap`

| Method | Description |
|---|---|
| `initialize(context, apiKey)` | Initialize SDK and download models |
| `downloadModelsIfNeeded(context)` | Pre-download models from CDN |
| `enrollFace(bitmap)` | Extract face embedding from Bitmap |
| `swapFace(bitmap, latent, lipMode)` | Swap face in a static image |
| `processFrame(bitmap, latent, lipMode)` | Process a single Bitmap (for custom pipelines) |
| `release()` | Clean up resources |

### Shared Types

| Type | Description |
|---|---|
| `FaceLatent` | 512-dim face embedding — reusable, cacheable, thread-safe |
| `LipMode` | Lip blending: `none`, `outerLips`, `innerLips` (default) |

---

## Billing

- **Per-session pricing** — Each `initialize()` call = 1 session. All subsequent operations within that session are free.
- **No per-frame charges** — Run the live camera for hours with zero additional cost.
- **Free model caching** — Models download once and are cached locally.
- **Dashboard** — Monitor usage at [sdk.amigoai.io/dashboard](https://sdk.amigoai.io/dashboard).

## Get an API Key

1. Sign up at [sdk.amigoai.io](https://sdk.amigoai.io)
2. Create a project in the dashboard
3. Copy your API key
4. Start building

---

## Documentation

| Resource | Link |
|---|---|
| iOS SDK Documentation | [documents/ios/SDK_DOCUMENTATION.md](documents/ios/SDK_DOCUMENTATION.md) |
| iOS Example Runbook | [examples/ios/README.md](examples/ios/README.md) |
| iOS SPM Package | [github.com/AmigoAIAdmin/AmigoSDK_iOS](https://github.com/AmigoAIAdmin/AmigoSDK_iOS) |

---

## License

The Amigo Face Swap SDK is commercially licensed. See [LICENSE](LICENSE.md) for details.

Contact [sdk@amigoai.io](mailto:sdk@amigoai.io) for enterprise licensing.

---

<p align="center">
Built by <a href="https://amigoai.io">Amigo AI</a>
</p>
