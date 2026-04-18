# System Architecture

NullSignal is built on a resilient, layered architecture designed to function in "Zero-Signal" environments.

## 1. Layered Overview

### UI Layer (Flutter)
*   **Orchestration:** Uses `UIOrchestratorCubit` to switch between **Normal** (Dashboard) and **Panic** (High-Intensity) modes.
*   **Aesthetic:** Tactical Beige/Red palette designed for high visibility and reduced eye strain in emergency environments.
*   **Visuals:** 
    *   **3D Mesh Topology:** Real-time spatial projection of nearby nodes using a custom 3D coordinate engine.
    *   **Animated Dynamics:** Fragmented line-shading and pulsing technical rings for interactive feedback.
    *   **Glitch Effects:** Used for high-intensity alerts and cryptographic status updates.

### Intelligence Layer (AIService)
*   **Android:** Integrates **Gemini Nano** via the ML Kit GenAI Prompt API.
*   **iOS:** Integrates **Gemma-2B** via MediaPipe/CoreML.
*   **Logic:** Handles local triage scoring and first-aid guidance without internet.

### Security Layer (SecurityService)
*   **Identity:** Persistent Ed25519 KeyPairs stored in **Isar DB**.
*   **E2EE:** X25519 Diffie-Hellman key exchange for direct peer-to-peer messaging.
*   **Integrity:** Every packet is cryptographically signed and verified at every hop.

### Transport Layer (MeshService)
*   **Engine:** Powered by Google's **Nearby Connections API** (P2P_CLUSTER strategy).
*   **Radios:** Leverages Bluetooth Low Energy (BLE), WiFi Direct, and Classic Bluetooth simultaneously.
*   **Routing:** Custom `RoutingEngine` with persistent **DTN (Delay-Tolerant Networking)** store for loop prevention and multi-hop relay.

## 2. Data Persistence (Isar DB)
NullSignal uses Isar for high-performance local storage:
*   **IdentityStore:** Local device ID and private keys.
*   **PeerRegistry:** Discovered peer public keys and last-seen metadata.
*   **MeshHistory:** Full log of incoming/outgoing packets.
*   **SeenCache:** Persistent IDs of relayed packets to prevent network storms.

## 3. Architecture Diagram
Refer to `null_signal/nullsignal_arch_ondevice.svg` for a visual representation of component interactions.
