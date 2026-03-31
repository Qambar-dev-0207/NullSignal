import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';

class RoutingEngine {
  final int maxCacheSize = 1000;
  final Set<String> _seenPacketIds = <String>{};

  /// Determines if a packet should be forwarded to others
  bool shouldForward(MeshPacket packet, String currentDeviceId) {
    // Don't forward if we've seen it before
    if (_seenPacketIds.contains(packet.packetId)) return false;
    
    // Don't forward if TTL is expired
    if (packet.ttl <= 0) return false;
    
    // Mark as seen
    _addToCache(packet.packetId);
    
    // Don't forward if it's meant for us (unless it's a broadcast)
    if (packet.receiverId == currentDeviceId) return false;
    
    return true;
  }

  /// Selects the best next hop based on priority, battery, and RSSI
  MeshDevice? getBestNextHop(List<MeshDevice> candidates, MeshPacket packet) {
    if (candidates.isEmpty) return null;

    final connectedCandidates = candidates.where((d) => d.isConnected).toList();
    if (connectedCandidates.isEmpty) return null;

    // Prioritize Gateway nodes if it's a gateway relay packet
    if (packet.isGatewayRelay) {
      final gateways = connectedCandidates.where((d) => d.isGateway).toList();
      if (gateways.isNotEmpty) return _selectByBattery(gateways);
    }

    // Weight selection based on Battery level and RSSI
    return _selectByBattery(connectedCandidates);
  }

  MeshDevice _selectByBattery(List<MeshDevice> candidates) {
    // Simple heuristic: pick device with highest battery above 20% threshold
    candidates.sort((a, b) => (b.batteryLevel ?? 0).compareTo(a.batteryLevel ?? 0));
    return candidates.first;
  }

  void _addToCache(String packetId) {
    if (_seenPacketIds.length >= maxCacheSize) {
      _seenPacketIds.remove(_seenPacketIds.first);
    }
    _seenPacketIds.add(packetId);
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
}
