import 'package:flutter_test/flutter_test.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';
import 'package:null_signal/features/mesh/domain/repositories/routing_engine.dart';

void main() {
  late RoutingEngine routingEngine;

  setUp(() {
    routingEngine = RoutingEngine();
  });

  group('RoutingEngine Tests', () {
    final testPacket = MeshPacket(
      packetId: 'p1',
      senderId: 's1',
      senderPublicKey: 'mock_key',
      payload: 'hello',
      signature: 'sig',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      ttl: 5,
      priority: PacketPriority.medium,
      latitude: 0.0,
      longitude: 0.0,
    );

    test('shouldForward returns true for new packet with TTL > 0', () {
      expect(routingEngine.shouldForward(testPacket, 'my_id'), isTrue);
    });

    test('shouldForward returns false for seen packet (Loop Prevention)', () {
      routingEngine.shouldForward(testPacket, 'my_id');
      expect(routingEngine.shouldForward(testPacket, 'my_id'), isFalse);
    });

    test('shouldForward returns false for packet with TTL = 0', () {
      final expiredPacket = MeshPacket(
        packetId: 'p2',
        senderId: 's1',
        senderPublicKey: 'mock_key',
        payload: 'hello',
        signature: 'sig',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        ttl: 0,
        priority: PacketPriority.medium,
        latitude: 0.0,
        longitude: 0.0,
      );
      expect(routingEngine.shouldForward(expiredPacket, 'my_id'), isFalse);
    });

    test('getBestNextHop picks device with highest battery', () {
      final deviceLow = MeshDevice(
        deviceId: 'd1',
        deviceName: 'Low',
        status: MeshDeviceStatus.connected,
        batteryLevel: 0.3,
      );
      final deviceHigh = MeshDevice(
        deviceId: 'd2',
        deviceName: 'High',
        status: MeshDeviceStatus.connected,
        batteryLevel: 0.8,
      );

      final best = routingEngine.getBestNextHop([deviceLow, deviceHigh], testPacket);
      expect(best?.deviceId, equals('d2'));
    });

    test('getBestNextHop prioritizes Gateways for gateway relay packets', () {
      final deviceHighBattery = MeshDevice(
        deviceId: 'd1',
        deviceName: 'High',
        status: MeshDeviceStatus.connected,
        batteryLevel: 0.9,
        isGateway: false,
      );
      final deviceGateway = MeshDevice(
        deviceId: 'd2',
        deviceName: 'Gateway',
        status: MeshDeviceStatus.connected,
        batteryLevel: 0.4,
        isGateway: true,
      );

      final gatewayPacket = MeshPacket(
        packetId: 'p3',
        senderId: 's1',
        senderPublicKey: 'mock_key',
        payload: 'hello',
        signature: 'sig',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        ttl: 5,
        priority: PacketPriority.medium,
        latitude: 0.0,
        longitude: 0.0,
        isGatewayRelay: true,
      );

      final best = routingEngine.getBestNextHop([deviceHighBattery, deviceGateway], gatewayPacket);
      expect(best?.deviceId, equals('d2'));
    });
  });
}
