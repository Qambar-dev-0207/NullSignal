# NullSignal Mesh Intelligence Documentation

## Architecture Overview
The Mesh Intelligence layer in NullSignal provides a decentralized, multi-hop communication backbone that functions without cellular or internet infrastructure.

### Core Components

#### 1. MeshService (`lib/core/services/mesh_service.dart`)
An abstract interface defining the contract for peer-to-peer discovery and communication.
- **`NearbyMeshServiceImpl`**: Concrete implementation using Google's Nearby Connections (BLE & WiFi Direct).
- **`SimulatedMeshService`**: Development mock for testing UI/UX in emulators.

#### 2. RoutingEngine (`lib/features/mesh/domain/repositories/routing_engine.dart`)
Pure logic component for pathfinding and multi-hop forwarding.
- **Loop Prevention:** Uses an LRU cache of `seenPacketIds` to block duplicate packet processing.
- **TTL (Time To Live):** Decremented per hop; zero-TTL packets are dropped.
- **Signature Enforcement:** Every incoming packet is verified using the sender's public key. Invalid packets are discarded immediately.
- **Gateway Prioritization:** Specifically routes `isGatewayRelay` packets toward nodes with active internet status.

#### 3. GatewayMonitor (`lib/core/services/gateway_monitor.dart`)
Monitors system-level connectivity (WiFi/Cell). Nodes with internet access advertise themselves with a `|G` suffix, allowing the mesh to automatically discover and use them as bridges to the cloud.

#### 4. SecurityService (`lib/core/services/security_service.dart`)
- **Identity:** Uses **Ed25519** for cryptographic device identity and packet signatures.
- **E2EE:** Implements **X25519** Diffie-Hellman key exchange to derive 256-bit shared secrets for direct peer-to-peer messaging.
- **Payload Protection:** All direct messages are encrypted via **AES-256-GCM** before mesh transmission.

### Data Model: MeshPacket
- **`senderPublicKey`**: Required for cryptographic verification of every hop.
- **`priority`**: Critical (SOS) packets bypass standard queues.
- **`isGatewayRelay`**: Triggers internet bridging when received by a Gateway Node.

## Protocol Flow

### Multi-hop Transmission
1. **Source** signs the payload and broadcasts the `MeshPacket`.
2. **Intermediate Node** receives, verifies signature, decrements TTL, and re-broadcasts if `RoutingEngine` approves.
3. **Gateway Node** receives packet with `isGatewayRelay: true`, verifies, and bridges to internet via fallback APIs.

### Secure Direct Messaging
1. **Handshake:** Nodes discover each other's `senderPublicKey` from standard mesh heartbeats/SOS.
2. **Derivation:** `MeshCubit` uses the local private key and peer's public key to derive a shared secret.
3. **Encryption:** Message is encrypted with AES-GCM and sent as a targeted `MeshPacket`.
4. **Reception:** Only the node with the matching private key can decrypt the payload.
