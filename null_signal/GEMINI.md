# NullSignal - Project Context

## Project Overview
NullSignal is a decentralized emergency communication and intelligence system designed for scenarios where traditional infrastructure has failed. It provides life-saving coordination using on-device AI and peer-to-peer mesh networking.

### Main Technologies
*   **Framework:** Flutter (Dart)
*   **Database:** [Isar](https://isar.dev/) (High-performance NoSQL)
*   **Mesh Networking:** [Nearby Connections API](https://developers.google.com/nearby/connections/overview)
*   **State Management:** [flutter_bloc](https://pub.dev/packages/flutter_bloc)
*   **Security:** [cryptography](https://pub.dev/packages/cryptography) (X25519, Ed25519, AES-256-GCM)
*   **AI:** [google_generative_ai](https://pub.dev/packages/google_generative_ai) (Gemini Nano on Android, Gemma on iOS)
*   **Mapping:** [flutter_map](https://pub.dev/packages/flutter_map)
*   **Theme:** Tactical Beige & Red (Designed for emergency clarity)
*   **Visuals:** Real-time 3D Mesh Topology Visualizer

### Core Architecture
The project follows a **Clean Architecture** pattern organized by feature:
*   **Core:** Shared models (`MeshPacket`, `Identity`), theme, and foundational services (`MeshService`, `SecurityService`).
*   **AI Layer:** Orchestrates on-device inference for triage, resource matching, and report synthesis.
*   **Mesh Layer:** Handles P2P discovery and multi-hop packet routing.
*   **Intelligence Layer:** Manages situational awareness features like hazard overlays and seismic monitoring.
*   **SOS Layer:** Handles critical alerts, health monitoring, and the "Dead Man's Switch" safety monitor.

## Building and Running

### Prerequisites
*   Flutter SDK (>= 3.8.0)
*   Android 14+ or iOS 17+ (Required for native AI and satellite features)
*   Physical device recommended for Mesh features (Emulators use `SimulatedMeshService`)

### Key Commands
*   **Install Dependencies:** `flutter pub get`
*   **Generate Code:** `dart run build_runner build --delete-conflicting-outputs`
*   **Static Analysis:** `flutter analyze`
*   **Run Tests:** `flutter test`
*   **Run App:** `flutter run --dart-define=GEMINI_API_KEY=your_key_here`

> **Note:** AI features require a build-time `GEMINI_API_KEY` for cloud fallback if native on-device AI is unavailable.

## Development Conventions

### Coding Standards
*   **State Management:** Use `Bloc` or `Cubit` for UI logic.
*   **Persistence:** Define Isar schemas in `lib/core/models/` and run `build_runner`.
*   **Dependency Injection:** Use `RepositoryProvider` and `BlocProvider` in `NullSignalApp` (`lib/main.dart`) for service and state distribution.
*   **Privacy:** Prioritize on-device processing. No PII should be broadcast without encryption.

### Testing Practices
*   Tests are located in the `test/` directory.
*   Use `mocktail` for mocking dependencies like Isar or Service classes.
*   Critical paths (E2EE, Routing, Safety Monitor) should have comprehensive unit and widget tests.

### Architecture Structure
```text
lib/
├── core/
│   ├── models/       # Isar schemas and shared models
│   ├── services/     # Foundational system services
│   └── theme/        # App styling and custom widgets
└── features/
    ├── ai/           # On-device triage and synthesis
    ├── dashboard/    # Main UI and navigation
    ├── intelligence/ # Hazard maps and seismic sensing
    ├── mesh/         # P2P Transport and discovery
    └── sos/          # Emergency triggers and monitoring
```
