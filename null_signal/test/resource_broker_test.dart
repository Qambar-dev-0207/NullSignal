import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/core/models/resource_packet.dart';
import 'package:null_signal/features/ai/data/repositories/resource_broker_service.dart';
import 'package:rxdart/rxdart.dart';

import 'package:cryptography/cryptography.dart';

class MockMeshService extends Mock implements MeshService {}
class MockAIService extends Mock implements AIService {}
class MockSecurityService extends Mock implements SecurityService {}
class MeshPacketFake extends Fake implements MeshPacket {}
class KeyPairFake extends Fake implements KeyPair {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ResourceBrokerService broker;
  late MockMeshService mockMesh;
  late MockAIService mockAi;
  late MockSecurityService mockSecurity;
  late Isar isar;
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
    registerFallbackValue(MeshPacketFake());
    registerFallbackValue(KeyPairFake());
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_resource_test');
    isar = await Isar.open(
      [MeshPacketSchema],
      directory: tempDir.path,
    );
    mockMesh = MockMeshService();
    mockAi = MockAIService();
    mockSecurity = MockSecurityService();
    
    when(() => mockMesh.deviceId).thenReturn('TEST_DEVICE');
    when(() => mockMesh.incomingPackets).thenAnswer((_) => const Stream.empty());
    
    final dummyKey = SimpleKeyPairData([], publicKey: SimplePublicKey([], type: KeyPairType.ed25519), type: KeyPairType.ed25519);
    when(() => mockSecurity.getOrCreateIdentity()).thenAnswer((_) async => dummyKey);
    when(() => mockSecurity.sign(any(), any())).thenAnswer((_) async => 'dummy_signature');

    broker = ResourceBrokerService(mockMesh, mockAi, isar, mockSecurity);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('ResourceBrokerService Tests', () {
    test('broadcastOffer sends a mesh packet with correct payload', () async {
      when(() => mockMesh.sendPacket(any())).thenAnswer((_) async => {});

      await broker.broadcastOffer('Insulin', 'Type 1', ResourceCategory.medical, 5);

      verify(() => mockMesh.sendPacket(any(that: isA<MeshPacket>().having(
        (p) => p.payload, 'payload', contains('RESOURCE_EXCHANGE')
      )))).called(1);
    });

    test('matches on medical resources in simulation mode', () async {
      final packetSubject = PublishSubject<MeshPacket>();
      when(() => mockMesh.incomingPackets).thenAnswer((_) => packetSubject.stream);
      
      final matchesExpectation = expectLater(
        broker.matchesStream,
        emitsInOrder([
          isEmpty,
          isNotEmpty,
        ]),
      );

      broker.start();
      
      // Simulate incoming medical need packet
      final packet = MeshPacket(
        packetId: 'P1',
        senderId: 'REMOTE_PEER',
        senderPublicKey: '',
        payload: 'RESOURCE_EXCHANGE:{"resourceName":"Insulin","description":"Need urgently","type":"NEED","quantity":1,"category":"medical"}',
        signature: '',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        ttl: 3,
        priority: PacketPriority.medium,
        latitude: 0.0,
        longitude: 0.0,
      );
      
      packetSubject.add(packet);

      await matchesExpectation;
      
      broker.stop();
      packetSubject.close();
    });
  });
}
