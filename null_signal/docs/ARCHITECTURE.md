# NullSignal — System Architecture

## 1. Layer Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  PRESENTATION  (Flutter UI + Cubits)                            │
│  MeshCubit · AiCubit · SosCubit · IntelligenceCubit            │
│  PanicNavigationWrapper · SOSBroadcastScreen                    │
│  PanicNearbyScreen · PanicAiHelpScreen · NormalDashboardScreen  │
├─────────────────────────────────────────────────────────────────┤
│  DOMAIN  (Abstract Interfaces + Entities)                       │
│  AIService · MeshService · IntelligenceService                  │
│  MeshInsightService · RoutingEngine · SafetyMonitor             │
│  MeshPacket · MeshDevice · SectorSummary · Peer                 │
├─────────────────────────────────────────────────────────────────┤
│  DATA  (Implementations)                                        │
│  AndroidAIService · IosAIService · GeminiAIService              │
│  NearbyMeshServiceImpl · SimulatedMeshService                   │
│  IntelligenceServiceImpl · MeshInsightServiceImpl               │
│  ResourceBrokerService                                          │
├─────────────────────────────────────────────────────────────────┤
│  CORE  (Cross-cutting)                                          │
│  SecurityService · GatewayMonitor · SatelliteGatewayService     │
│  SafetyMonitor · FeedbackService                                │
│  Isar DB: MeshPacket · Identity · Peer · Contact               │
│           ChatMessage · SeenPacket · SectorSummary              │
├─────────────────────────────────────────────────────────────────┤
│  PLATFORM  (Native)                                             │
│  Android: MainActivity.kt — LiteRT-LM (Gemma 4 E2B)            │
│  Android: Nearby Connections API                                │
│  iOS: AppDelegate.swift — CoreML / Metal                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Feature Modules

### AI Feature (`lib/features/ai/`)

**Stack:**
```
AiCubit
  └── GeminiAIService          ← orchestrator (online fallback + delegation)
        ├── AndroidAIService   ← MethodChannel → MainActivity.kt → LiteRT-LM
        └── IosAIService       ← MethodChannel → AppDelegate.swift → CoreML
```

**Android AI engine (LiteRT-LM):**
- SDK: `com.google.ai.edge.litertlm:litertlm-android`
- Model: `gemma-4-E2B-it.litertlm` (~2.58 GB, Gemma 4 Effective 2B)
- Init path (priority order):
  1. Copy from APK asset (`assets/models/gemma-4-E2B-it.litertlm`) → `filesDir`
  2. Download from HuggingFace if asset absent
- GPU backend → CPU fallback on load failure
- Progress streamed to Flutter via `onProgress` MethodChannel call (0–100, −1 = error)

**iOS AI engine:**
- CoreML / Metal inference
- Gemma 3 1B or similar via MediaPipe iOS

**Online fallback:**
- `GeminiAIService` uses `gemini-1.5-flash` if `GEMINI_API_KEY` is set and node has internet
- Priority: native AI → cloud AI → built-in heuristics

**Background services:**
- `MeshInsightServiceImpl` — synthesizes incoming peer reports into `SectorSummary` every 5 min
- `ResourceBrokerService` — AI-powered need/supply matching across mesh

---

### Mesh Feature (`lib/features/mesh/`)

**Stack:**
```
MeshCubit
  └── NearbyMeshServiceImpl   ← Google Nearby Connections
        └── RoutingEngine     ← DTN multi-hop routing
```

**Transport:**
- Strategy: `P2P_CLUSTER` (simultaneous BLE + WiFi Direct + BT Classic)
- Service ID: `com.nullsignal.p2p`
- Advertising name: `{deviceId}` or `{deviceId}|G` for gateway nodes

**Connection lifecycle:**
1. `startAdvertising` + `startDiscovery` (3 retries each)
2. `onEndpointFound` → deterministic initiator (lower logical ID initiates)
3. `requestConnection` → `acceptConnection` (both sides accept)
4. `onConnectionResult` → CONNECTED / REJECTED / ERROR
5. Auto-reconnect on disconnect (+5 s delay)
6. Discovery restart every 45 s if zero peers visible

**Packet security (every packet):**
- Ed25519 signed by sender before transmission
- Verified at every receiving hop — invalid packets dropped immediately
- E2EE optional for direct messages: X25519 DH → AES-256-GCM

**Routing:**
- `SeenPacket` cache in Isar — deduplicates relayed packets
- TTL decremented per hop, zero-TTL packets dropped
- Gateway-priority forwarding for `isGatewayRelay=true` packets
- Cache pruned every hour (entries > 24 h removed)
- Heartbeat every 60 s (TTL=1, signed)

---

### Intelligence Feature (`lib/features/intelligence/`)

| Capability | Mechanism |
|---|---|
| Hazard overlays | GeoJSON polygons from gateway, broadcast as mesh packet, 10 km radius filter |
| Crowd crush prediction | BLE neighbor count every 5 min + AI risk analysis if count > 5 |
| Seismic scoring | Accelerometer 15G threshold, 30 s debounce, distributed heatmap |
| Damage heatmap | Aggregated magnitude reports from up to 100 mesh nodes |

---

### SOS Feature (`lib/features/sos/`)

- `SosCubit.broadcastSos()` — signs and sends `MeshPacket` with `priority=CRITICAL`, `TTL=5`, `isGatewayRelay=true`
- Re-broadcasts every 15 s with new packet IDs (bypasses dedup, sustains relay)
- Dead Man Switch: 8 min inactivity → check-in prompt → 30 s grace → auto-SOS
- `SafetyMonitor` drives DMS independently of UI state

---

## 3. Dependency Injection (main.dart)

```
Isar.open(schemas)
  → SecurityService(isar)        → identity + crypto
  → GatewayMonitor()             → internet uplink detection
  → SatelliteGatewayService()
  → SafetyMonitor()
  → NearbyMeshServiceImpl(gw, sec, isar, sat)   [physical device]
  → SimulatedMeshService(gw, sec, isar)          [emulator]
  → AndroidAIService() / IosAIService()
  → GeminiAIService(apiKey, nativeService)
  → MeshInsightServiceImpl(mesh, ai, isar)
  → ResourceBrokerService(mesh, ai, isar, sec)
  → IntelligenceServiceImpl(mesh, gw, ai, sec)
  → NullSignalApp(MultiRepositoryProvider + MultiBlocProvider)
```

---

## 4. Data Persistence (Isar DB)

| Collection | Contents |
|---|---|
| `Identity` | `deviceId` (Node_uuid), Ed25519 private key seed |
| `Peer` | Discovered peer IDs, public keys, last-seen timestamps |
| `MeshPacket` | Full packet history (all incoming/outgoing) |
| `SeenPacket` | Packet IDs seen — prevents relay storms |
| `ChatMessage` | Local AI conversation history |
| `SectorSummary` | AI-synthesized mesh intelligence summaries |
| `Contact` | User-created contact directory |

---

## 5. Security Model

```
Identity:     Ed25519 keypair, generated once, stored encrypted in Isar
Signing:      Every outgoing MeshPacket signed with Ed25519 private key
Verification: Every received packet verified before processing/relaying
E2EE:         X25519 DH → 256-bit shared secret → AES-256-GCM encrypt
Relay nodes:  See only packet headers. Encrypted payloads are opaque.
```

---

## 6. Platform Notes

**Android:**
- `compileSdk 36`, `minSdk 31`, `targetSdk` from Flutter
- JDK 17 required
- `LiteRT-LM` AAR: `com.google.ai.edge.litertlm:litertlm-android`
- Manifest: `<uses-native-library android:name="libOpenCL.so" android:required="false"/>` for GPU

**iOS:**
- Xcode 15+, iOS 17+
- Gemma via CoreML / Metal (Swift bridging header)
- `IosAIService` mirrors Android API surface via MethodChannel

**Emulator:**
- `SimulatedMeshService` auto-selected when `androidInfo.isPhysicalDevice == false`
- Simulates fluctuating node topology, no real radios used
