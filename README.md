# Amigo Face Swap SDK

**On-device, real-time face swap for iOS and Android.**

Amigo is a production-grade face swap SDK that runs entirely on-device. No server round-trips, no cloud processing, no privacy concerns. Drop it into your app and ship real-time face swap in minutes.

[![Platform](https://img.shields.io/badge/platform-iOS%2016%2B-blue)](#platform-support)
[![Android](https://img.shields.io/badge/Android-Coming%20Soon-lightgrey)](#android--coming-soon)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)](#quick-start--ios)
[![License](https://img.shields.io/badge/license-Commercial-green)](#license)

---

## Why Amigo?

| | Amigo SDK | Cloud-based alternatives |
|---|---|---|
| **Latency** | Real-time (30 fps on-device) | 2–10s per image (network round-trip) |
| **Privacy** | Images never leave the device | Images uploaded to third-party servers |
| **Offline** | Works without internet (after initial setup) | Requires constant connectivity |
| **Cost** | Per-session billing, unlimited frames | Per-image or per-minute billing |
| **Quality** | 512×512 CoreML neural pipeline | Varies |

## Features

- **Real-time face swap** — 30 fps live camera processing with CoreML + Metal
- **Static image face swap** — High-quality single-image processing
- **On-device ML inference** — Zero network latency, complete user privacy
- **Face enrollment** — Extract reusable 512-dim face embeddings from any photo
- **Lip blending modes** — Natural lip sync with configurable blending (none, outer, inner)
- **Background replacement** — Real-time person segmentation with custom backgrounds
- **SwiftUI & Jetpack Compose** — Native UI components for modern app architectures
- **UIKit & Android Views** — Full support for traditional UI frameworks
- **Per-frame API** — Direct `CVPixelBuffer` processing for WebRTC, video playback, and custom pipelines
- **Hot-swappable faces** — Switch between enrolled face identities at runtime with zero latency

## Platform Support

| Platform | ML Runtime | Resolution | UI Components |
|---|---|---|---|
| **iOS 16+** | CoreML + Metal | 512×512 | SwiftUI, UIKit |
| **Android API 26+** | TensorFlow Lite + GPU | 256×256 | Jetpack Compose, Android Views (coming soon) |

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

## Android — Coming Soon

The Android SDK is under active development. Stay tuned for the release.

Interested in early access? Contact us at [support@amigoai.io](mailto:support@amigoai.io).

---

## Architecture

```
┌──────────────────────────────────────┐
│             Your App                 │
│  ┌────────────────────────────────┐  │
│  │      Amigo Face Swap SDK      │  │
│  │                                │  │
│  │  Face Enrollment               │  │
│  │  Face Swap Engine              │  │
│  │  Live Camera Session           │  │
│  │                                │  │
│  │  ┌──────────────────────────┐  │  │
│  │  │  CoreML / TFLite Runtime  │  │  │
│  │  │   (Metal GPU Accelerated)│  │  │
│  │  └──────────────────────────┘  │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

All processing happens on-device. The only network calls are API key validation (once per session) and model downloads (once, then cached).

---

## Examples

This repository contains fully working example apps:

| Platform | Location | Features |
|---|---|---|
| **iOS** | [`examples/ios/AmigoExample`](examples/ios/) | Static swap, live camera, photo picker |
| **Android** | Coming soon | — |

Each example includes step-by-step setup instructions. See the [iOS Runbook](examples/ios/README.md) to get started.

---

## API Overview

### iOS — `AmigoFaceSwap`

| Method | Description |
|---|---|
| `initialize(apiKey:onProgress:)` | Initialize SDK and download models |
| `enrollFace(from:)` | Extract 512-dim face embedding from UIImage |
| `swapFace(in:using:lipMode:)` | Swap face in a static image |
| `processFrame(_:using:lipMode:)` | Process a single CVPixelBuffer (for custom pipelines) |
| `clearModelCache()` | Force re-download on next init |

### Shared Types

| Type | Description |
|---|---|
| `FaceLatent` | 512-dim face embedding — reusable, cacheable, thread-safe |
| `LipMode` | Lip blending: `none`, `outerLips`, `innerLips` (default) |

---

## Billing

- **Per-session pricing** — Each `initialize()` call = 1 session. All subsequent operations within that session are free.
- **No per-frame charges** — Run the live camera for hours with zero additional cost.
- **Free model caching** — Models are downloaded once and cached locally.
- **Dashboard** — Monitor usage at [sdk.amigoai.io/dashboard](https://sdk.amigoai.io/dashboard).

## Get an API Key

1. Visit [sdk.amigoai.io](https://sdk.amigoai.io) and sign up for an account
2. Create a project in the dashboard
3. Copy your API key
4. Start building

Need help? Contact us at [support@amigoai.io](mailto:support@amigoai.io).

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

Contact [support@amigoai.io](mailto:support@amigoai.io) for enterprise licensing.

---

<p align="center">
Built by <a href="https://amigoai.io">Amigo AI</a>
</p>
