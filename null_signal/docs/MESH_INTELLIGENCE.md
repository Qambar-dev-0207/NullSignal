# NullSignal — Mesh Intelligence

## 1. Transport Layer

### Physical Radios
Google Nearby Connections (`P2P_CLUSTER` strategy) simultaneously uses:
- **BLE** (Bluetooth Low Energy) — discovery + low-power data
- **WiFi Direct** — high-throughput data transfer
- **Bluetooth Classic** — fallback transport

Service ID: `com.nullsignal.p2p`

### Why P2P_CLUSTER?
`P2P_CLUSTER` allows every device to act as both advertiser and discoverer simultaneously. All devices are peers — no single master. Partitions heal automatically when devices come back into range.

---

## 2. Discovery & Pairing

### Advertising
```
name: "{deviceId}"          — regular node
name: "{deviceId}|G"        — gateway node (has internet uplink)
strategy: P2P_CLUSTER
serviceId: com.nullsignal.p2p
retries: 3 (backoff: 3s, 6s)
```

### Discovery
```
endpointName: own deviceId
retries: 3 (backoff: 3s, 6s)
```

### Discovery Restarter
Timer fires every 45 s. If `_discoveredDevices.isEmpty`:
1. Stop advertising + discovery
2. Restart both — clears any stale Nearby state

### Connection Initiation (deterministic, no storms)
On `onEndpointFound`:
```
if (localDeviceId.compareTo(remoteLogicalName) < 0) → initiate connection
else → wait for remote to initiate
```
Lower lexicographic ID always initiates. Prevents both devices racing to connect simultaneously.

### Connection Handshake
```
requestConnection(timeout=30s)
  → onConnectionInitiated (both sides)
  → acceptConnection (both sides)
  → onConnectionResult: CONNECTED | REJECTED | ERROR
```

Auto-reconnect on disconnect: 5 s delay, then `connect()`.

---

## 3. MeshPacket Structure

```dart
MeshPacket {
  packetId:        UUIDv4                // deduplication key
  senderId:        "Node_xxxx"           // logical device ID
  senderPublicKey: String                // base64 Ed25519 public key
  receiverId?:     "Node_xxxx"           // null = broadcast
  packetType:      String?
  payload:         String                // plaintext or AES-GCM ciphertext
  signature:       String                // base64 Ed25519 signature
  timestamp:       int                   // epoch ms
  ttl:             int                   // 1–5, decremented per hop
  priority:        LOW | MEDIUM | HIGH | CRITICAL
  latitude:        double
  longitude:       double
  isGatewayRelay:  bool                  // triggers internet bridge on gateway
}
```

---

## 4. Packet Security

Every packet at every hop:
1. **Verify signature:** `Ed25519.verify(payload, signature, senderPublicKey)` → drop if invalid
2. **Check SeenPacket cache:** drop if already processed
3. **Process or forward** based on `receiverId`

### E2EE Direct Messages
```
MeshCubit.sendDirectMessage:
  1. Retrieve recipient's senderPublicKey from MeshDevice
  2. X25519 DH → shared secret
  3. AES-256-GCM encrypt payload
  4. Send as MeshPacket with receiverId set
  5. Relay nodes forward ciphertext, cannot read payload
```

---

## 5. DTN Routing Engine

### Deduplication
`SeenPacket` (Isar) stores `{packetId, timestamp}`. Every received packet checked before processing. Prevents relay storms. Pruned every hour — entries older than 24 h removed.

### Forwarding Decision
```
receive packet
  → verify signature
  → check SeenPacket cache (drop if seen)
  → mark as seen
  → if receiverId == us: emit to incomingPackets
  → if receiverId == null (broadcast): emit + forward
  → if receiverId == other: forward only
  → decrement TTL (drop if TTL <= 0)
  → sendPacket to all connected peers
```

### Next-Hop Selection
- Prefers gateway nodes for `isGatewayRelay=true` packets
- Battery-level weighting (higher battery nodes preferred as relay)
- Currently floods to all connected peers within TTL — no source routing

### TTL Values by Use Case
| Packet type | TTL |
|---|---|
| Heartbeat | 1 |
| Direct message | 3 |
| SOS broadcast | 5 |
| Resource packet | 3 |

---

## 6. Gateway Node

A node becomes a gateway when `GatewayMonitor` detects an active internet connection (WiFi or cellular).

Gateway nodes:
- Advertise with `|G` suffix so peers know to route relay packets to them
- On receiving a packet with `isGatewayRelay=true`:
  ```
  HTTP POST https://api.nullsignal.io/v1/sos/relay
  {packetId, senderId, coordinates, payload, timestamp}
  timeout: 5s
  ```
- If HTTP fails: `SatelliteGatewayService` attempts satellite escalation

---

## 7. Heartbeat

- Fires every 60 s if at least one peer is connected
- `TTL=1, priority=LOW, payload="HEARTBEAT"`
- Ed25519 signed
- Not stored in chat history, not emitted to UI
- Allows peers to learn sender's public key without needing an explicit exchange

---

## 8. Key Implementation Files

| File | Role |
|---|---|
| `lib/core/services/mesh_service.dart` | Abstract interface |
| `lib/features/mesh/data/repositories/nearby_mesh_service_impl.dart` | Nearby Connections implementation |
| `lib/features/mesh/data/repositories/simulated_mesh_service.dart` | Emulator mock |
| `lib/features/mesh/domain/repositories/routing_engine.dart` | DTN routing logic |
| `lib/features/mesh/presentation/bloc/mesh_cubit.dart` | UI state + E2EE message dispatch |
| `lib/core/services/security_service.dart` | Crypto (Ed25519 + X25519 + AES-GCM) |
| `lib/core/services/gateway_monitor.dart` | Internet uplink detection |

---

## 9. Known Constraints

| Constraint | Detail |
|---|---|
| Nearby Connections BLE range | ~100 m line-of-sight, ~30 m through walls |
| Max concurrent connections | Platform-dependent, typically 3–5 on Android |
| Packet size | Nearby Connections max payload ~1 MB (well within MeshPacket usage) |
| `neverForLocation` flag | Must NOT be set on `BLUETOOTH_SCAN` or `NEARBY_WIFI_DEVICES` — breaks discovery |
| `ACCESS_FINE_LOCATION` | Must be granted at runtime — Nearby Connections requires it regardless of Android version |
