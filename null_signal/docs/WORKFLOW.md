# Operational Workflow

This document explains how NullSignal handles emergency events and mesh network maintenance.

## 1. The SOS Lifecycle

1.  **Trigger:** User taps "SEND SOS" or the **SafetyMonitor** (Dead Man's Switch) detects 8 minutes of inactivity.
2.  **Telemetry:** System fetches real-time GPS coordinates via the `geolocator`.
3.  **Signing:** The SOS payload is combined with coordinates and signed using the device's persistent **Ed25519** private key.
4.  **Broadcast:** The packet is injected into the mesh via `NearbyMeshServiceImpl`.
5.  **Relay:** Nearby nodes receive the packet, verify the signature, and re-broadcast it if the TTL (Time-To-Live) is > 0.
6.  **Escalation:** If a node with internet access (a "Gateway") receives the SOS, it automatically bridges it to the `api.nullsignal.io` emergency endpoint.

## 2. Mesh Discovery & Trust

*   **Continuous Discovery:** Nodes constantly scan for peers.
*   **Identity Handshake:** When two nodes connect, they exchange public keys. These are saved in the persistent **PeerRegistry**.
*   **Trust Levels:** Users can mark specific nodes as "Trusted Contacts" or "Family."
*   **E2EE Setup:** Once public keys are known, nodes can initiate a secure session using AES-256-GCM for private 1-on-1 coordination.

## 3. AI Triage Workflow

*   **Input:** User provides symptoms or injury descriptions via the AI Help tab.
*   **Local Inference:** The request is sent through a `MethodChannel` to the native AI core (Gemini Nano on Android).
*   **Actionable Advice:** The AI returns a START triage color and prioritized medical steps.
*   **Persistence:** The consultation is saved to the **Isar ChatMessage** store for future reference by medics.

## 4. Loop Prevention (DTN Store)

To prevent the mesh from being flooded by the same packet:
1.  Every packet has a unique UUID.
2.  The `RoutingEngine` checks the Isar `SeenPacket` store.
3.  If the UUID exists, the packet is silently dropped.
4.  If not, it is stored and relayed.
