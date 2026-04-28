# NullSignal — AI & Safety Intelligence

## 1. AI Architecture

### Service Hierarchy

```
GeminiAIService  (orchestrator)
├── AndroidAIService  ←  MethodChannel  →  MainActivity.kt  →  LiteRT-LM
├── IosAIService      ←  MethodChannel  →  AppDelegate.swift →  CoreML/Metal
└── Gemini 1.5-Flash  ←  google_generative_ai  (online fallback only)
```

`GeminiAIService` tries each path in order and falls back on failure:
1. Native on-device model (if loaded and `isProvisioned == true`)
2. Cloud Gemini (if `GEMINI_API_KEY` set and internet available)
3. Built-in heuristic rules (always available)

---

## 2. Android AI Engine — LiteRT-LM

### Model
- **Gemma 4 E2B** (`gemma-4-E2B-it.litertlm`, ~2.58 GB)
- Quantized for mobile inference
- Context window: up to 32k tokens

### SDK
- `com.google.ai.edge.litertlm:litertlm-android`
- `Engine` + `Conversation` API
- GPU backend with automatic CPU fallback

### Initialization flow (`MainActivity.kt`)
1. Delete legacy `.litertlm` files from failed prior attempts
2. Check `filesDir` for existing model file
3. If missing/incomplete → copy from APK asset `assets/models/gemma-4-E2B-it.litertlm` (if bundled)
4. If still missing → download from HuggingFace with resume support (5 retries)
5. Load `Engine` with GPU backend → fallback to CPU if GPU fails
6. Emit `onProgress = 100` on success, `-1` on error

### Progress streaming
`AndroidAIService` receives `onProgress` calls via MethodChannel and exposes them as `Stream<int> downloadProgress`. `AiCubit` subscribes and drives `TacticalAiProvisioningScreen`.

### Guards
- `isInitializing` flag prevents concurrent init calls (hot-restart, duplicate callers)
- `isInitialized` flag skips re-download on subsequent `initializeModel` calls
- Load failures delete the model file for clean re-download on next attempt

---

## 3. iOS AI Engine

- `IosAIService` bridges to Swift via MethodChannel (`com.nullsignal/aicore`)
- Runs Gemma model via CoreML / Metal on iPhone 12+
- `isProvisioned` is set to `true` only after `initialize()` completes (not assumed on startup)

---

## 4. Online Fallback — Gemini 1.5-Flash

- Active only when `GEMINI_API_KEY` is injected at build time
- Used by gateway nodes with internet uplink
- Model: `gemini-1.5-flash` (temperature 0.4, maxTokens 1024)
- Never used for privacy-sensitive payloads — mesh messages are never forwarded to cloud

---

## 5. AI Capabilities

### Emergency Triage (START Protocol)
Input: free-text symptom description
Output: triage color + reasoning

| Color | Criteria |
|---|---|
| BLACK | No pulse, no breathing, non-salvageable |
| RED | Immediate life threat (airway, circulation) |
| YELLOW | Serious, non-life-threatening |
| GREEN | Walking wounded / minor injuries |

Heuristic fallback active when model not yet loaded.

### First-Aid Guidance
- Snake bite, wound care, burn management: pre-loaded protocols (instant, zero inference)
- All other conditions: native AI → cloud AI → generic message

### Conversational Assistant
- Context window: last 6 messages (Gemma 4 prompt template)
- Persistent history stored in Isar `ChatMessage` collection
- History survives app restarts

### Mesh Insight Synthesis (`MeshInsightServiceImpl`)
- Runs every 5 minutes when peers are present
- Gathers incoming `MeshPacket` payloads from recent window
- AI summarizes → `SectorSummary` written to Isar
- Summaries surfaced in AiCubit state for display

### Resource Broker (`ResourceBrokerService`)
- Listens for NEED/HAVE resource packets from mesh
- AI matches needs against available supply
- Broadcasts matched pairing as a direct `MeshPacket`

---

## 6. Security Layer (`SecurityService`)

### Cryptographic Standards

| Algorithm | Use |
|---|---|
| Ed25519 | Device identity keypair, per-packet signing and verification |
| X25519 | Diffie-Hellman key exchange for shared secret derivation |
| AES-256-GCM | Authenticated end-to-end encryption of direct messages |

### Identity
- Generated once on first launch: `Node_<uuid8>`
- Ed25519 private key seed stored in Isar `Identity` collection
- Reconstructed from seed on subsequent launches (deterministic)

### Packet Signing
Every outgoing `MeshPacket` is signed with the sender's Ed25519 private key. `senderPublicKey` (base64 Ed25519) is included in the packet for verification at every hop. Packets with invalid signatures are dropped immediately.

### End-to-End Encryption (Direct Messages)
```
1. Sender derives X25519 key pair from Ed25519 identity
2. Sender derives shared secret: X25519(own_private, recipient_ed25519_public)
3. Payload encrypted: AES-256-GCM(plaintext, shared_secret) → base64
4. Relay nodes forward ciphertext — cannot decrypt
5. Recipient derives same shared secret, decrypts payload
```

---

## 7. Safety Layer (`SafetyMonitor`)

### Dead Man Switch
1. Monitors device accelerometer via `sensors_plus`
2. Inactivity threshold: 8 minutes of zero significant motion
3. Displays `SAFETY CHECK-IN` dialog with haptic feedback
4. If user does not confirm within 30 s → auto-SOS broadcast

### Auto-SOS Packet
- `SosCubit.broadcastSos()` called with coordinates (GPS or fallback)
- Priority: `CRITICAL`, TTL: 5, `isGatewayRelay: true`
- Re-broadcasts every 15 s until manually stopped

### Satellite Escalation
`SatelliteGatewayService` attempts escalation via Android Satellite SOS API after SOS broadcast, providing last-resort connectivity when no mesh gateway exists.
