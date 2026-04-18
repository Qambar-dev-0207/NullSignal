# NullSignal

**Decentralized Emergency Communication & Intelligence System**

NullSignal is a next-generation emergency response platform designed for scenarios where traditional infrastructure (cellular, internet, power) has failed. It leverages on-device AI and peer-to-peer mesh networking to provide life-saving coordination.

## ⚡ Advanced Features (2026 Emergency Spec)

*   **Offline Mesh Intelligence:** On-device AI (Gemini Nano) analyzes incoming reports to provide local triage guidance and situational awareness.
*   **Mesh Insight Synthesis:** Automatically condenses hundreds of incoming mesh reports into high-level "Sector Summaries" to prevent information overload for rescue teams.
*   **Real-time Hazard Overlays:** Gateway nodes fetch vector fire/flood boundaries from Google Earth Engine, compressing and broadcasting them across the mesh for live offline map overlays.
*   **Crowd Crush Prediction:** Analyzes BLE neighbor density and rate-of-change using on-device AI to broadcast early warning alerts and evacuation vectors.
*   **Seismic Damage Scoring:** Correlates real-time accelerometer spikes and node silence across the mesh to generate structural damage heatmaps without GPS or internet.
*   **Satellite-Mesh Hybridization:** Integrates with the Android Satellite SOS API to funnel critical SOS packets through satellite-enabled devices.
*   **AI Resource Matching:** A P2P "Resource Exchange" where on-device AI act as brokers, matching survivor needs with available supplies via mesh-wide telemetry.
*   **E2EE Security:** All mesh communication is signed and encrypted using Ed25519 and AES-GCM to prevent spoofing and ensure data integrity.

## 🏗️ Architecture

NullSignal is built with Flutter and follows a Clean Architecture pattern:

- **Core:** Shared models, E2EE security services, and mesh communication protocols.
- **Mesh Layer:** Handles P2P discovery and multi-hop packet routing using Google's Nearby Connections.
- **AI Layer:** Orchestrates on-device inference using Gemini Nano for synthesis, crowd risk, and triage.
- **Intelligence Layer:** Manages hazard overlays, seismic monitoring, and structural damage heatmaps.
- **SOS Layer:** Manages critical alerts and health monitoring.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Android 14+ (for Satellite & Native AI features) or iOS 17+
- Gemini API Key (for cloud fallback)

### Installation
1. Clone the repository.
2. Run `flutter pub get`.
3. Generate schemas: `dart run build_runner build`.
4. Run on a physical device: `flutter run`.

## 🛡️ Safety & Privacy
- **Zero-Trust mesh:** Every packet is cryptographically verified.
- **On-Device First:** AI synthesis and resource matching happen locally to ensure privacy and low-bandwidth efficiency.
- **Automatic Escalation:** SOS alerts automatically seek the fastest path out (Internet -> Satellite -> Mesh).
