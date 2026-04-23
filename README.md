# NullSignal

**Decentralized Emergency Communication & Intelligence System**

NullSignal is a resilient, offline-first communication platform designed for environments where traditional cellular and internet infrastructure have failed. It turns every phone into a node in a secure, intelligent mesh network.

## 🚀 Key Features

*   **P2P Mesh Networking:** Communicate without internet or cell towers using BLE and WiFi Direct via Nearby Connections.
*   **Offline AI (Gemma 4):** Advanced on-device medical triage and first-aid guidance powered by Google's **Gemma 4 E2B IT** via LiteRT-LM.
*   **Industrial-Grade Security:** Full End-to-End Encryption (E2EE) and Ed25519 identity signatures for every mesh node.
*   **Dead Man's Switch:** Automated SOS broadcasting if the user becomes incapacitated (Safety Monitor).
*   **Internet Bridging:** Automatic escalation of signals to the cloud via active gateway nodes or satellite links.

## 📖 Documentation

*   **[Setup & Installation](null_signal/README.md#installation):** Get the app running on your devices.
*   **[Technical Spec (GEMINI.md)](null_signal/GEMINI.md):** Detailed architectural overview for AI agents and developers.

## 🛠 Tech Stack

*   **Frontend:** Flutter (Dart)
*   **Database:** Isar (NoSQL)
*   **Local AI:** Gemma 4 E2B (LiteRT-LM / MediaPipe)
*   **Transport:** Nearby Connections API (BLE/WiFi Direct)
*   **Security:** Ed25519, X25519, AES-256-GCM

---
*Built for resilience. Built to save lives.*
