# NullSignal

**Decentralized Emergency Communication & Intelligence System**

NullSignal is a next-generation emergency response platform designed for scenarios where traditional infrastructure (cellular, internet, power) has failed. It leverages on-device AI and peer-to-peer mesh networking to provide life-saving coordination.

## ⚡ Advanced Features (2026 Emergency Spec)

*   **Gemma 4 Offline Intelligence:** Powered by Google's **Gemma 4 Effective 2B (E2B)** model via LiteRT-LM. Provides advanced reasoning, triage guidance, and situational awareness without internet.
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
- **AI Layer:** Orchestrates on-device inference using **Gemma 4** for synthesis, crowd risk, and triage.
- **Intelligence Layer:** Manages hazard overlays, seismic monitoring, and structural damage heatmaps.
- **SOS Layer:** Manages critical alerts and health monitoring.

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK:** >= 3.8.0
- **Android:** 14+ (requires physical device for Mesh & LiteRT features). 4GB+ RAM recommended.
- **iOS:** 17+ (physical device required).
- **Hugging Face Token:** Required for downloading Gemma 4 model weights.

### Installation
1.  **Clone the repository.**
2.  **Configure HF Token:** Add your Hugging Face read token to `null_signal/android/local.properties`:
    ```properties
    hf.token=hf_your_token_here
    ```
3.  **Accept Model License:** Ensure you have accepted the Gemma 4 license at [Hugging Face](https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm).
4.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
5.  **Generate Schemas:**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
6.  **Run on a physical device:**
    ```bash
    flutter clean
    flutter run --dart-define=GEMINI_API_KEY=your_cloud_key
    ```

## 🛡️ Safety & Privacy
- **Zero-Trust mesh:** Every packet is cryptographically verified using Ed25519.
- **On-Device First:** AI synthesis and resource matching happen locally using LiteRT-LM to ensure privacy and low-bandwidth efficiency.
- **Automatic Escalation:** SOS alerts automatically seek the fastest path out (Internet -> Satellite -> Mesh).
