# Setup & Installation Guide

## 1. Prerequisites

### Software
| Requirement | Version |
|---|---|
| Flutter SDK | >= 3.8.0 |
| Dart SDK | >= 3.8.0 (bundled with Flutter) |
| Android Studio / VS Code | Latest, with Flutter + Dart plugins |
| Android SDK | API 36 (compileSdk), API 31+ on device |
| JDK | 17 (required by Kotlin / AGP) |
| Xcode (iOS only) | 15+ on macOS |

### Hardware
- **Physical Android device required** — Nearby Connections and LiteRT-LM do not work on emulators.
- **RAM:** 4 GB+ recommended (Gemma 4 E2B loads ~2 GB into memory at runtime).
- **Storage:** 3 GB+ free internal storage (model + DB + operating headroom).
- **iOS:** iPhone 12 or newer for CoreML/Metal performance.

> Emulators auto-select `SimulatedMeshService` and heuristic AI fallback — usable for UI work only.

---

## 2. Clone & Install

```bash
git clone https://github.com/your-repo/null_signal.git
cd null_signal/null_signal

flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## 3. Configure HF Token

Add to `android/local.properties` (create if missing):

```properties
sdk.dir=/path/to/Android/Sdk
hf.token=hf_your_huggingface_token_here
```

The token is embedded at build time via `BuildConfig.HF_TOKEN`. It is only used if the model is fetched over the network (download fallback path). If bundling the model as an asset, the token is not needed at runtime.

---

## 4. Bundle the AI Model (Recommended)

Bundling packages the model inside the APK — the app works offline from day one with zero network dependency.

### Step 1 — Accept license
Accept the Gemma 4 license at:
```
https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm
```

### Step 2 — Download model
Download `gemma-4-E2B-it.litertlm` (~2.58 GB):
```
https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm
```

### Step 3 — Place file
```
null_signal/android/app/src/main/assets/models/gemma-4-E2B-it.litertlm
```

The `.gitignore` in that folder excludes the binary from git automatically.

### What happens at runtime
1. First launch: app detects asset, copies to `filesDir` (~30–60 s), emits progress to UI.
2. Subsequent launches: file already in `filesDir`, skip copy, load immediately.
3. If asset absent: app falls back to network download (requires internet + valid HF token + accepted license).

### APK size
Bundled APK is ~2.6 GB. Side-load via `adb install` works fine. For Play Store use Play Asset Delivery (`install-time` delivery pack).

---

## 5. Download Fallback (No Bundling)

If you skip bundling, the app downloads the model on first launch:
- Requires stable Wi-Fi (2.58 GB download)
- HF token must be valid and have read access
- Gemma 4 license must be accepted on HuggingFace
- 5 retry attempts with resume support
- Progress shown on `TacticalAiProvisioningScreen`

---

## 6. Run

```bash
# Standard run (offline AI + mesh)
flutter run

# With online Gemini fallback for gateway nodes
flutter run --dart-define=GEMINI_API_KEY=your_gemini_api_key
```

### Build APK (sideload)
```bash
flutter build apk --split-per-abi
# Output: build/app/outputs/flutter-apk/
```

### Clean rebuild
```bash
flutter clean && flutter pub get && flutter run
```

---

## 7. First Launch Checklist

1. Grant all requested permissions:
   - Fine Location (required for Nearby Connections BLE discovery)
   - Bluetooth Scan / Advertise / Connect
   - Nearby Wi-Fi Devices
2. Wait for AI provisioning screen to complete (first run: 30–60 s copy, or full download)
3. Confirm mesh scanning starts (MESH tab shows "Scanning...")
4. On second device: repeat. Devices should discover each other within 15 s.

---

## 8. Permissions Reference

Declared in `AndroidManifest.xml`:

| Permission | Why |
|---|---|
| `ACCESS_FINE_LOCATION` | Nearby Connections requires location for BLE peer discovery |
| `ACCESS_COARSE_LOCATION` | Supplementary location |
| `BLUETOOTH_SCAN` | BLE scanning for peer discovery |
| `BLUETOOTH_ADVERTISE` | Broadcasting device presence |
| `BLUETOOTH_CONNECT` | Establishing BT connections |
| `NEARBY_WIFI_DEVICES` | WiFi Direct peer discovery |
| `ACCESS_BACKGROUND_LOCATION` | Sustained mesh when app is backgrounded |
| `INTERNET` | Gateway relay + HF download fallback |

> `BLUETOOTH_SCAN` and `NEARBY_WIFI_DEVICES` must **not** have `usesPermissionFlags="neverForLocation"`. Nearby Connections uses location-derivation from radio scans — that flag silently prevents peer discovery.

---

## 9. Code Generation

Required after any change to Isar model files (`core/models/` or `features/*/data/models/`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files (`*.g.dart`, `*.isar.dart`) are committed to the repo.

---

## 10. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Mesh discovers 0 peers | Missing `ACCESS_FINE_LOCATION` grant or wrong BT flags | Grant fine location; check manifest has no `neverForLocation` |
| AI stuck at 0% | Model copy/download not triggered | Check logcat for `[MediaPipe]` tag |
| AI shows "LOAD_FAILED" | Wrong model format or SDK mismatch | Ensure `.litertlm` file (not `.task`) in assets |
| "Connection interrupted" loop | Old corrupt file in `filesDir` | Use `forceRedownload()` button in AI settings |
| Build fails: JDK version | Wrong Java version | Set `JAVA_HOME` to JDK 17 |
| iOS missing signing | Xcode provisioning not set | Configure team + bundle ID in Xcode |
