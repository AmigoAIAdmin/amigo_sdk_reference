# Amigo Face Swap SDK

**On-device, real-time face swap for iOS and Android.**

AmigoSDK is a production-grade face swap SDK that runs entirely on-device. No server round-trips, no cloud processing, no privacy concerns. Drop it into your app and ship real-time face swap in minutes.

> **💡 Not a developer? or Just want to try it?** Try our consumer app — experience real-time face swap without writing any code at [Amigo AI](https://www.amigoai.io/download)

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

## How Amigo Compares

The face-swap landscape splits into three categories: open-source research stacks ([inswapper_128](https://github.com/deepinsight/insightface) / InsightFace and derivatives like [Deep-Live-Cam](https://github.com/hacksider/Deep-Live-Cam), Roop, Rope) and cloud-hosted generative services ([Higgsfield](https://higgsfield.ai), Akool, Vidnoz, etc.). Amigo is a different shape from both:

| | **inswapper_128** (InsightFace) | **Deep-Live-Cam** | **Cloud services** (Higgsfield, etc.) | **Amigo SDK** |
|---|---|---|---|---|
| **Execution model** | Local inference, self-hosted | Local inference, desktop app | Offline batch jobs — upload → render queue → download | **Live real-time**, on-device, per-frame |
| **Latency** | Depends on your GPU | Real-time only on NVIDIA discrete GPU | Seconds to minutes per asset + network round-trip | **30 fps on-device**, millisecond per-frame |
| **Output resolution** | 128×128 (needs GFPGAN/CodeFormer restorer to look HD) | 128×128 (uses inswapper_128 under the hood) | Varies (typically high-res one-shot renders) | **512×512 iOS · 256×256 Android** |
| **Deployment target** | Desktop / server, Python | Desktop with discrete GPU, Python | Third-party cloud | **iOS 16+ and Android API 26+**, native |
| **Runtime** | ONNX Runtime | ONNX Runtime + OpenCV + restorer | Their servers | CoreML + Metal (iOS), TFLite + GPU (Android) |
| **Developer experience** | Raw ONNX model — you build detection, alignment, blending, camera, UI, hosting yourself | Desktop Python app — not a library, no mobile bindings, no public API | REST API — you handle async job state, polling, retries, error UX | **3-line integration.** Drop-in SwiftUI / Jetpack Compose view, enrollment API, per-frame API, UIKit + async/await |
| **Cost model** | "Free" model + your own GPU + bandwidth bill if server-hosted; license violation if shipped client-side | Free if your users have NVIDIA GPUs | **Per-generation credits** — every image/video costs you money; viral features = viral bills | **Per-session flat pricing.** One `initialize()` = unlimited frames, swaps, and live-camera minutes |
| **Scalability** | Linear cost per user × frame on your GPU cluster; cloud GPU becomes your product ceiling | Doesn't — gated on user hardware | Exposed to their render queue, capacity, pricing changes, and uptime | **Scales with users' devices, not your servers.** 10 or 10M users → $0 per-frame infra cost |
| **Privacy** | You host it, you own the data path | Local only | **User photos uploaded to third-party servers** — GDPR / CCPA / minor-user compliance burden | **Images never leave the device.** No cloud inference, no uploads, no data-residency review |
| **Offline** | N/A (self-hosted) | Yes | No — requires constant connectivity | **Yes** — works after initial model download |
| **Licensing** | Non-commercial / research only — shipping it is a license violation | Inherits inswapper_128's non-commercial restriction | Commercial, per their TOS | **Commercial SDK** with SLA |

**TL;DR** — inswapper_128 and Deep-Live-Cam are research tools, not shippable mobile products. Cloud services are built for creators rendering finished assets, not for apps responding to user input in real time. Amigo is a mobile-first, commercially licensed SDK for interactive, live, in-app face-swap experiences — with zero per-frame infra cost.

---

<p align="center">
Built by <a href="https://amigoai.io">Amigo AI</a>
</p>
