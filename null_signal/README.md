# NullSignal

**Decentralized Emergency Communication & Intelligence System**

Operates when all traditional infrastructure (cellular, internet, power) has failed. Phones form a secure, AI-assisted P2P mesh. No cloud required.

---

## Features

| Feature | Detail |
|---|---|
| **Offline AI** | Gemma 4 E2B on-device via LiteRT-LM (Android) · CoreML/Metal (iOS) |
| **Mesh Network** | Google Nearby Connections — BLE + WiFi Direct + BT Classic |
| **DTN Routing** | Multi-hop relay with TTL, SeenPacket dedup, gateway prioritization |
| **E2EE Security** | Ed25519 signing · X25519 DH · AES-256-GCM per packet |
| **Triage AI** | START triage scoring (GREEN / YELLOW / RED / BLACK) |
| **Mesh Insight** | AI condenses peer reports → Sector Summaries every 5 min |
| **Resource Broker** | AI-matched P2P pairing of survivor needs ↔ supplies |
| **Hazard Overlays** | GeoJSON fire/flood polygons fetched by gateway nodes, broadcast offline |
| **Crowd Crush** | BLE density + AI risk analysis → early evacuation broadcast |
| **Seismic Scoring** | Accelerometer 15G threshold → distributed damage heatmap |
| **Dead Man Switch** | 8 min inactivity → check-in prompt → auto-SOS |
| **Satellite Relay** | Android Satellite SOS API integration for last-resort escalation |

---

## Architecture

```
Presentation  MeshCubit · AiCubit · SosCubit · IntelligenceCubit
Domain        MeshService · AIService · IntelligenceService (abstract)
Data          NearbyMeshServiceImpl · AndroidAIService · IntelligenceServiceImpl
Core          SecurityService · GatewayMonitor · SafetyMonitor · Isar DB
Platform      Kotlin/MainActivity (LiteRT-LM) · Nearby Connections API
```

Full architecture and mesh P2P diagrams: see `docs/ARCHITECTURE.md`.

---

## Requirements

- **Flutter:** >= 3.8.0, Dart >= 3.8.0
- **Android:** 14+ (minSdk 31), physical device required for mesh + AI
- **iOS:** 17+, physical device required
- **RAM:** 4 GB+ recommended (Gemma 4 E2B runtime)
- **Storage:** 3 GB free (model copy + operating headroom)

---

## Getting Started

### 1. Install dependencies
```bash
cd null_signal
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 2. Configure HF token (for runtime download fallback only)
Add to `null_signal/android/local.properties`:
```properties
hf.token=hf_your_token_here
```

### 3. Bundle the AI model (recommended — true offline, no network needed)

Download `gemma-4-E2B-it.litertlm` (~2.58 GB) from:
```
https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm
```
Accept the Gemma 4 license on HuggingFace first.

Place at:
```
null_signal/android/app/src/main/assets/models/gemma-4-E2B-it.litertlm
```

The app copies the file to internal storage on first launch (~30–60 s). Subsequent launches skip this step. The `.gitignore` in that folder prevents the binary from being committed.

> If you skip this step, the app falls back to downloading the model at runtime (requires network + valid HF token + accepted license).

### 4. Run
```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_optional
```

`GEMINI_API_KEY` is optional — only used as online AI fallback on gateway nodes with internet.

---

## Permissions

Granted at runtime on first launch:

| Permission | Purpose |
|---|---|
| `ACCESS_FINE_LOCATION` | Required by Nearby Connections for BLE peer discovery |
| `BLUETOOTH_SCAN / ADVERTISE / CONNECT` | P2P mesh radio control |
| `NEARBY_WIFI_DEVICES` | WiFi Direct peer discovery |
| `ACCESS_BACKGROUND_LOCATION` | Sustained mesh operation when app is backgrounded |

> **Important:** `BLUETOOTH_SCAN` must NOT have `usesPermissionFlags="neverForLocation"`. Nearby Connections requires location-derivation from BLE scans — that flag silently kills discovery.

---

## Safety & Privacy

- **Zero-trust mesh:** Every packet is Ed25519-signed and verified at every hop.
- **On-device first:** All AI inference, triage, and resource matching run locally via LiteRT-LM.
- **E2EE direct messages:** X25519 DH → AES-256-GCM. Relay nodes see routing headers only.
- **Escalation chain:** Internet → Satellite → Mesh (automatic, no user action required).
