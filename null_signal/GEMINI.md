# NullSignal - Project Context

## Project Overview
NullSignal is a decentralized emergency communication and intelligence system designed for scenarios where traditional infrastructure has failed. It provides life-saving coordination using on-device AI and peer-to-peer mesh networking.

### Main Technologies
*   **Framework:** Flutter (Dart)
*   **Database:** [Isar](https://isar.dev/) (High-performance NoSQL)
*   **Mesh Networking:** [Nearby Connections API](https://developers.google.com/nearby/connections/overview)
*   **State Management:** [flutter_bloc](https://pub.dev/packages/flutter_bloc)
*   **Security:** [cryptography](https://pub.dev/packages/cryptography) (X25519, Ed25519, AES-256-GCM)
*   **AI:** [LiteRT-LM](https://ai.google.dev/edge/litert) (Gemma 4 E2B IT optimized for Edge)
*   **Mapping:** [flutter_map](https://pub.dev/packages/flutter_map)
*   **Theme:** Tactical Beige & Red (Designed for emergency clarity)

### Core Architecture
The project follows a **Clean Architecture** pattern organized by feature:
*   **Core:** Shared models (`MeshPacket`, `Identity`), theme, and foundational services (`MeshService`, `SecurityService`).
*   **AI Layer:** Orchestrates on-device inference using **Gemma 4** for triage, resource matching, and report synthesis.
*   **Mesh Layer:** Handles P2P discovery and multi-hop packet routing.
*   **Intelligence Layer:** Manages situational awareness features like hazard overlays and seismic monitoring.
*   **SOS Layer:** Handles critical alerts, health monitoring, and the "Dead Man's Switch" safety monitor.

## Building and Running

### Prerequisites
*   Flutter SDK (>= 3.8.0)
*   Android 14+ or iOS 17+ (Requires physical device for Mesh & native AI)
*   **Hugging Face Token:** Must be added to `android/local.properties` as `hf.token=...`
*   **RAM:** 4GB+ recommended for Gemma 4 GPU acceleration.

### Key Commands
*   **Clean & Sync:** `flutter clean && flutter pub get`
*   **Generate Code:** `dart run build_runner build --delete-conflicting-outputs`
*   **Static Analysis:** `flutter analyze`
*   **Run App:** `flutter run --dart-define=GEMINI_API_KEY=your_key_here`

> **Note:** AI features use **Gemma 4 E2B** locally via LiteRT-LM. Initialization triggers a ~2.6GB background download on the first boot. A **`hf.token`** is mandatory for authentication.

## Development Conventions

### Coding Standards
*   **State Management:** Use `Bloc` or `Cubit` for UI logic.
*   **Logging:** Use `developer.log` with high-visibility tags (`[SYSTEM]`, `[AI]`, `[MESH]`).
*   **Resilient Networking:** Implement resumable downloads and domain-aware header stripping for gated model weights.

### Testing Practices
*   **Integration Tests:** Use `integration_test/ai_verification_test.dart` for on-device AI validation.
*   **Unit Tests:** Critical paths (E2EE, Routing, Safety Monitor) have comprehensive unit tests in the `test/` directory.

### Architecture Structure
```text
lib/
├── core/
│   ├── models/       # Isar schemas and shared models
│   ├── services/     # Foundational system services
│   └── theme/        # App styling and custom widgets
└── features/
    ├── ai/           # On-device triage and synthesis (Gemma 4 / LiteRT-LM)
    ├── dashboard/    # Main UI and navigation
    ├── intelligence/ # Hazard maps and seismic sensing
    ├── mesh/         # P2P Transport (Nearby Connections)
    └── sos/          # Emergency triggers and monitoring
```
