# NullSignal Mesh Intelligence Documentation

## Architecture Overview
The Mesh Intelligence layer in NullSignal provides a decentralized, multi-hop communication backbone that functions without cellular or internet infrastructure.

### Core Components

#### 1. MeshService (`lib/core/services/mesh_service.dart`)
An abstract interface defining the contract for peer-to-peer discovery and communication.
- **`NearbyMeshService`**: The concrete implementation using Google's Nearby Connections API (BLE & WiFi Direct).

#### 2. RoutingEngine (`lib/features/mesh/domain/repositories/routing_engine.dart`)
A pure logic component responsible for determining the best path for data packets.
- **Loop Prevention:** Uses an LRU cache of `seenPacketIds` (size: 1000) to ensure packets aren't forwarded repeatedly.
- **TTL (Time To Live):** Each hop decrements the TTL; packets with TTL=0 are discarded.
- **Priority-Weighted Routing:**
  - **Battery-Aware:** Prioritizes relaying through devices with higher battery levels.
  - **Gateway-Aware:** Automatically routes packets toward known Gateway Nodes if internet escalation is required (`isGatewayRelay: true`).

#### 3. GatewayMonitor (`lib/core/services/gateway_monitor.dart`)
Passively monitors device connectivity. If the device gains internet access (WiFi/Cell/Ethernet), it informs the mesh that it can now act as an internet gateway for others.

### Data Model: MeshPacket
The fundamental unit of communication in the mesh.
- **`packetId`**: Unique identifier for loop prevention.
- **`priority`**: Enum (Low to Critical). Critical packets (SOS) get routing priority.
- **`ttl`**: Number of hops remaining.
- **`isGatewayRelay`**: Flag to indicate the packet needs internet delivery.

## Multi-hop Flow
1. **Device A** sends a packet.
2. **Device B** (in range) receives it.
3. **RoutingEngine** on Device B checks `shouldForward()`.
4. If true, `RoutingEngine` selects the best next hop from connected peers.
5. **Device B** forwards the packet.
6. Process repeats until the packet reaches its destination or a Gateway Node.
