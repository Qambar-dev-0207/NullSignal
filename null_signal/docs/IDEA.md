# NullSignal: The Product Vision

## 1. The Goal (The "Why")
In the event of a natural disaster, conflict, or infrastructure collapse, the first thing to fail is often the "Single Point of Failure": the cellular network and the internet. Without communication, coordination becomes impossible, and preventable casualties increase.

**NullSignal’s mission is to provide a "Network of Last Resort."** 

Our goal is to turn every smartphone into a resilient, intelligent communication node that does not rely on towers, satellites, or central servers. We aim to democratize emergency coordination by placing the entire network stack—from transport to intelligence—directly on the user's device.

---

## 2. How It Is Done (The "How")

### Decentralized Mesh Networking
Instead of connecting to a tower, NullSignal nodes connect to each other. Using the **Nearby Connections API**, we create a dynamic mesh using Bluetooth Low Energy (BLE), WiFi Direct, and Classic Bluetooth. Packets hop from phone to phone until they reach their destination or an active internet gateway.

### On-Device Intelligence
Emergency medical advice shouldn't require a 5G connection. We integrate **Gemini Nano** (via ML Kit on Android) and **Gemma** (via MediaPipe on iOS) to provide local LLM inference. This allows survivors to receive medical triage and first-aid guidance in total isolation.

### Industrial-Grade Security
Decentralization often invites bad actors. NullSignal uses **Ed25519 signatures** to ensure that every SOS is authentic and **AES-256-GCM** for end-to-end encrypted (E2EE) messaging. Identities are persistent and stored in an encrypted local **Isar Database**.

### Delay-Tolerant Networking (DTN)
In a moving disaster zone, nodes are constantly entering and leaving range. Our **DTN Store** (Seen-ID Cache) ensures that packets are stored and relayed efficiently without causing network storms or infinite loops, allowing messages to "flow" through a moving crowd.

---

## 3. Core Features (The "What")

### 🚨 Emergency SOS & Telemetry
*   **One-Tap Broadcast:** Send a high-priority SOS packet to every device within the mesh.
*   **Real-time GPS:** Automatically attaches high-precision coordinates to the SOS signal using the device's hardware GPS.

### 🧠 Offline AI Triage
*   **Local Medical Consult:** AI identifies injury severity and provides a START triage color (Red/Yellow/Green).
*   **Step-by-Step Guidance:** Interactive first-aid instructions for trauma, bleeding, and respiratory issues.

### 🛡️ Safety Monitor (Dead Man's Switch)
*   **Inactivity Detection:** Uses accelerometer data to monitor for sudden stops or prolonged lack of movement.
*   **Auto-Escalation:** If a user is unresponsive to a safety check-in, the system automatically broadcasts an SOS with their last known location.

### 💬 Secure Coordination
*   **Direct Messaging:** 1-on-1 E2EE coordination for search-and-rescue teams or families.
*   **Mesh Cloud:** A real-time 3D visualization of the local network density and node health.

### 🌐 Gateway Escalation
*   **Internet Bridging:** If any single node in the mesh detects an internet connection, it acts as a "Gateway," automatically relaying all critical SOS signals from the offline mesh to global emergency services.

---

## 4. Supplementary & Utility Features

### 📊 Real-time Mesh Visualization
*   **3D Mesh Cloud:** An interactive, rotatable 3D visualization of the local peer network. Nodes are mapped dynamically, and data transmissions are visualized as animated pulses along connection lines.
*   **Signal Strength (RSSI) Tracking:** Visual indicators of connection quality between nodes to help users find the best position for a stable link.

### 🗄️ Robust Data Persistence (Isar DB)
*   **Encrypted Identity Store:** Your device identity, private keys, and trusted contact list are persisted locally and securely.
*   **Mission History:** Every AI consultation and received SOS is stored in a searchable local database, allowing for post-event analysis by medical professionals.
*   **Peer Registry:** Automatically remembers discovered nodes, their names, and their public keys to speed up secure handshake processes in future encounters.

### 🤝 Trust & Contact Management
*   **Trusted Contacts:** Mark specific nodes as "Trusted" or "Family."
*   **Secure Handshakes:** Automatic exchange of cryptographic public keys upon connection to enable zero-config E2EE for verified contacts.

### 📳 Tactical Feedback System
*   **Morse Code Haptics:** The phone uses specialized vibration patterns (e.g., Morse SOS) to notify the user of incoming emergency alerts even when the device is in a pocket or silent mode.
*   **High-Intensity Feedback:** Screen-shake and visual "Glitch" effects during active SOS broadcasts to provide tactile and visual confirmation of signal status.

---
**NullSignal isn't just an app; it's a decentralized safety net built for the most critical moments of human survival.**
