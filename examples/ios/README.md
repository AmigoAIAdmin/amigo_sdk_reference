# Amigo iOS Example App — Runbook

This guide walks you through building and running the Amigo Face Swap example app on iOS.

## Prerequisites

| Requirement | Minimum |
|---|---|
| macOS | 13.0+ (Ventura) |
| Xcode | 15.0+ |
| iOS device or simulator | iOS 16.0+ |
| Amigo API key | Get one at [sdk.amigoai.io/dashboard](https://sdk.amigoai.io/dashboard) |

> **Note:** Real-time face swap requires a physical device with a camera. The simulator works for static image swap only.

## Step 1 — Clone the Repository

```bash
git clone https://github.com/AmigoAIAdmin/amigo_sdk_reference.git
cd amigo_sdk_reference/examples/ios/AmigoExample
```

## Step 2 — Open in Xcode

```bash
open AmigoExample.xcodeproj
```

Xcode will automatically resolve the `AmigoFaceSwapSDK` Swift Package dependency from [AmigoSDK_iOS](https://github.com/AmigoAIAdmin/AmigoSDK_iOS). Wait for package resolution to complete (check **File → Packages → Resolve Package Versions** if needed).

## Step 3 — Add Your API Key

Open `AmigoExample/Secrets.swift` and replace the placeholder:

```swift
enum Secrets {
    static let amigoAPIKey = "your-api-key"  // ← paste your key here
}
```

> **Security:** Never commit your API key to a public repository.

## Step 4 — Build & Run

1. Select your target device (physical iPhone recommended for camera features).
2. Press **⌘R** to build and run.
3. On first launch, the SDK downloads ML models (~50 MB). A progress bar is shown during download.

## What the Example App Demonstrates

### Static Image Face Swap

1. Tap **"Swap Face on Image"** from the home screen.
2. Select a **source face** (the identity to apply) and a **target image** (the image whose face will be replaced).
3. Tap **"Swap Face"** — the SDK runs face enrollment + inference on-device and displays the result.

### Real-Time Live Face Swap

1. Tap **"Real-Time Face Swap"** from the home screen.
2. Grant camera permission when prompted.
3. The front camera feed appears with the default source face swapped in real time.
4. Tap **"Change Face"** to pick a different source face from your photo library.

## Troubleshooting

| Issue | Solution |
|---|---|
| "Set your API key in Secrets.swift" | You haven't replaced the placeholder in `Secrets.swift`. |
| Package resolution fails | Go to **File → Packages → Reset Package Caches**, then resolve again. |
| "No face was detected" | Ensure the source image contains a clearly visible, front-facing face. |
| Camera permission denied | Go to **Settings → Privacy → Camera** and enable access for AmigoExample. |
| Model download fails | Check your internet connection. The SDK caches models after the first download. |

## Project Structure

```
AmigoExample/
├── AmigoExampleApp.swift     # App entry point
├── SetupView.swift           # SDK initialization + model download progress
├── HomeView.swift            # Navigation to features
├── FaceSwapView.swift        # Static image face swap demo
├── LiveFaceSwapView.swift    # Real-time camera face swap demo
├── Secrets.swift             # API key configuration
└── Assets.xcassets/          # Default test images
```

## Next Steps

- Read the full [SDK Documentation](../../../documents/ios/SDK_DOCUMENTATION.md) for API reference and advanced usage.
- Explore the [main repository README](../../../README.md) for Android examples and more.
