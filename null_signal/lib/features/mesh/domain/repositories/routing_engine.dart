import 'package:isar/isar.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/models/contact.dart'; // Contains SeenPacket
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';

class RoutingEngine {
  final Isar _isar;

  RoutingEngine(this._isar);

  /// Determines if a packet should be forwarded to others
  Future<bool> shouldForward(MeshPacket packet, String currentDeviceId) async {
    // 1. TTL Check (Fast fail)
    if (packet.ttl <= 0) return false;

    // 2. Persistent Loop Prevention (Seen-IDs Cache)
    final existing = await _isar.seenPackets.filter().packetIdEqualTo(packet.packetId).findFirst();
    if (existing != null) return false;
    
    // 3. Destination Check
    if (packet.receiverId == currentDeviceId) {
      // Still mark as seen so we don't process it again if it circles back
      await _isar.writeTxn(() async {
        await _isar.seenPackets.put(SeenPacket(
          packetId: packet.packetId,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
      });
      return false;
    }
    
    // 4. Register as seen and return true for forwarding
    await _isar.writeTxn(() async {
      await _isar.seenPackets.put(SeenPacket(
        packetId: packet.packetId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    });
    
    return true;
  }

  /// Selects the best next hop based on priority, battery, and RSSI
  MeshDevice? getBestNextHop(List<MeshDevice> candidates, MeshPacket packet) {
    if (candidates.isEmpty) return null;

    final connectedCandidates = candidates.where((d) => d.isConnected).toList();
    if (connectedCandidates.isEmpty) return null;

    // DTN logic: Prioritize Gateway nodes if it's a gateway relay packet
    if (packet.isGatewayRelay) {
      final gateways = connectedCandidates.where((d) => d.isGateway).toList();
      if (gateways.isNotEmpty) return _selectByBattery(gateways);
    }

    return _selectByBattery(connectedCandidates);
  }

  MeshDevice _selectByBattery(List<MeshDevice> candidates) {
    candidates.sort((a, b) => (b.batteryLevel ?? 0).compareTo(a.batteryLevel ?? 0));
    return candidates.first;
  }

  MeshPacket decrementTtl(MeshPacket packet) {
    return MeshPacket(
      packetId: packet.packetId,
      senderId: packet.senderId,
      senderPublicKey: packet.senderPublicKey,
      receiverId: packet.receiverId,
      payload: packet.payload,
      signature: packet.signature,
      timestamp: packet.timestamp,
      ttl: packet.ttl - 1,
      priority: packet.priority,
      latitude: packet.latitude,
      longitude: packet.longitude,
      isGatewayRelay: packet.isGatewayRelay,
    );
  }

  /// Cleanup old seen IDs to keep DTN store lean (e.g. older than 24h)
  Future<void> pruneSeenCache() async {
    final dayAgo = DateTime.now().subtract(const Duration(hours: 24)).millisecondsSinceEpoch;
    await _isar.writeTxn(() async {
      await _isar.seenPackets.filter().timestampLessThan(dayAgo).deleteAll();
    });
  }
}
