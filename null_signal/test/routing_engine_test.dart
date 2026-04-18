import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/models/contact.dart'; // SeenPacket
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';
import 'package:null_signal/features/mesh/domain/repositories/routing_engine.dart';

void main() {
  late RoutingEngine routingEngine;
  late Isar isar;
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_routing_test');
    isar = await Isar.open(
      [SeenPacketSchema],
      directory: tempDir.path,
    );
    routingEngine = RoutingEngine(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
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

    test('decrementTtl reduces TTL by 1', () {
      final original = MeshPacket(
        packetId: 'p4',
        senderId: 's1',
        senderPublicKey: 'mock_key',
        payload: 'hello',
        signature: 'sig',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        ttl: 10,
        priority: PacketPriority.medium,
        latitude: 0.0,
        longitude: 0.0,
      );

      final decremented = routingEngine.decrementTtl(original);
      expect(decremented.ttl, equals(9));
      expect(decremented.packetId, equals(original.packetId));
    });

    test('shouldForward returns false if TTL <= 0', () async {
      final zeroTtlPacket = MeshPacket(
        packetId: 'p5',
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

      final shouldForward = await routingEngine.shouldForward(zeroTtlPacket, 'my_id');
      expect(shouldForward, isFalse);
    });

    test('shouldForward returns true for new packet and false for seen packet', () async {
      final packet = MeshPacket(
        packetId: 'new_p',
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

      // First time: should be true
      final firstResult = await routingEngine.shouldForward(packet, 'my_id');
      expect(firstResult, isTrue);

      // Second time: should be false (already seen)
      final secondResult = await routingEngine.shouldForward(packet, 'my_id');
      expect(secondResult, isFalse);
    });

    test('shouldForward returns false if packet is for current device', () async {
      final targetedPacket = MeshPacket(
        packetId: 'targeted_p',
        senderId: 's1',
        senderPublicKey: 'mock_key',
        receiverId: 'my_id',
        payload: 'hello',
        signature: 'sig',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        ttl: 5,
        priority: PacketPriority.medium,
        latitude: 0.0,
        longitude: 0.0,
      );

      final shouldForward = await routingEngine.shouldForward(targetedPacket, 'my_id');
      expect(shouldForward, isFalse);
    });

    test('pruneSeenCache removes old packets', () async {
      final oldTimestamp = DateTime.now().subtract(const Duration(hours: 48)).millisecondsSinceEpoch;
      final newTimestamp = DateTime.now().millisecondsSinceEpoch;

      await isar.writeTxn(() async {
        await isar.seenPackets.putAll([
          SeenPacket(packetId: 'old_p', timestamp: oldTimestamp),
          SeenPacket(packetId: 'new_p', timestamp: newTimestamp),
        ]);
      });

      await routingEngine.pruneSeenCache();

      final remaining = await isar.seenPackets.where().findAll();
      expect(remaining.length, equals(1));
      expect(remaining.first.packetId, equals('new_p'));
    });
  });
}
