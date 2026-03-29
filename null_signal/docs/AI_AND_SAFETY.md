# NullSignal AI & Safety Intelligence

This document outlines the intelligence and security layers of NullSignal, which enable on-device triage and secure communication.

## 1. AI Intelligence Layer
NullSignal provides offline AI assistance across both major mobile platforms through a unified `AIService` interface.

### Platform-Specific Engines
- **Android:** Utilizes **Gemini Nano** via the **Android AICore API**. This provides deep system integration and high performance on supported devices.
- **iOS:** Utilizes **Gemma-2B** via the **MediaPipe LLM Inference API**. This leverages the iPhone's GPU/NPU for equivalent offline reasoning.

### Capabilities
- **Emergency Triage:** Automated START triage scoring (Green/Yellow/Red) based on symptoms.
- **First-Aid Guidance:** Step-by-step instructions for CPR, bleeding control, and other critical interventions.
- **Multilingual Survival Tips:** Cross-language support for diverse disaster environments.

## 2. Security Layer (`SecurityService`)
NullSignal implements end-to-end encryption for all mesh traffic to protect survivor privacy and prevent malicious tampering.

### Cryptographic Standards
- **Encryption:** **AES-256-GCM** is used to encrypt message payloads.
- **Integrity:** **ECDSA (P-256)** is used to sign every packet.
- **Decentralized Identity:** Each device generates its own keypair on first launch. The public key serves as the `senderId`.

### Zero-Knowledge Relays
Relay nodes only process the routing metadata (`packetId`, `ttl`, `receiverId`). The message content remains encrypted and unreadable to any device other than the intended recipient or a trusted gateway.

## 3. Safety Layer (`SafetyMonitor`)
The "Dead Man's Switch" is a critical safety feature for incapacitated users.

### Monitoring Logic
1. **Motion Detection:** The app monitors the accelerometer via `sensors_plus`.
2. **Inactivity Timeout:** If no significant movement is detected for 8 minutes, the app triggers a high-priority local check-in prompt.
3. **Auto-SOS:** If the user does not dismiss the prompt within 30 seconds, NullSignal automatically broadcasts an SOS packet to the mesh containing the last known coordinates.
