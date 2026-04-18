# NullSignal AI & Safety Intelligence

This document outlines the intelligence and security layers of NullSignal, which enable on-device triage and secure communication.

## 1. AI Intelligence Layer
NullSignal provides offline AI assistance across both major mobile platforms through a unified `AIService` interface.

### Platform-Specific Engines
- **Android:** Utilizes **Gemini Nano** via the **ML Kit GenAI Prompt API** (powered by **Android AICore**). This provides high-performance local inference on supported Pixel and Samsung flagship devices.
- **iOS:** Utilizes **Gemma-2B** via the **MediaPipe LLM Inference API**. This leverages the iPhone's GPU/NPU for equivalent offline reasoning.

### Capabilities
- **Emergency Triage:** Automated START triage scoring (Green/Yellow/Red) based on symptoms.
- **First-Aid Guidance:** Step-by-step instructions for CPR, bleeding control, and other critical interventions.
- **Persistent Memory:** Conversational history is stored locally via **Isar DB**, allowing users to refer back to prior AI guidance even after app restarts.

## 2. Security Layer (`SecurityService`)
NullSignal implements industrial-grade cryptography to protect survivor privacy and prevent malicious tampering in decentralized environments.

### Cryptographic Standards
- **Identity & Signatures:** Uses **Ed25519** for high-speed, secure device identity and packet-level integrity. Every mesh packet is verified at every hop.
- **Key Exchange:** Implements **X25519 (Diffie-Hellman)** for secure peer-to-peer shared secret derivation.
- **Encryption:** **AES-256-GCM** provides authenticated end-to-end encryption (E2EE) for direct messages.
- **Zero-Knowledge Relays:** Intermediate nodes only process routing metadata. Message payloads remain unreadable to everyone except the intended recipient.

## 3. Safety Layer (`SafetyMonitor`)
The "Dead Man's Switch" provides automated protection for incapacitated users.

### Monitoring Logic
1. **Motion Detection:** Monitors device accelerometer via `sensors_plus`.
2. **Inactivity Timeout:** Triggers after 8 minutes of zero significant motion.
3. **Local Check-in:** Displays a high-priority "SAFETY CHECK-IN" overlay with haptic feedback.
4. **Auto-SOS:** If the user fails to confirm safety within 30 seconds, the system automatically broadcasts an SOS packet to the entire mesh network.
