import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/gateway_monitor.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/intelligence/data/repositories/intelligence_service_impl.dart';
import 'package:rxdart/rxdart.dart';

class MockMeshService extends Mock implements MeshService {}
class MockGatewayMonitor extends Mock implements GatewayMonitor {}
class MockAIService extends Mock implements AIService {}
class MockSecurityService extends Mock implements SecurityService {}
class MeshPacketFake extends Fake implements MeshPacket {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockMeshService mockMesh;
  late MockGatewayMonitor mockGateway;
  late MockAIService mockAi;
  late MockSecurityService mockSecurity;

  setUpAll(() {
    registerFallbackValue(MeshPacketFake());
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  setUp(() {
    mockMesh = MockMeshService();
    mockGateway = MockGatewayMonitor();
    mockAi = MockAIService();
    mockSecurity = MockSecurityService();
    
    when(() => mockMesh.deviceId).thenReturn('TEST_DEVICE');
    when(() => mockMesh.incomingPackets).thenAnswer((_) => const Stream.empty());
    when(() => mockMesh.sendPacket(any())).thenAnswer((_) async => {});
  });

  group('IntelligenceService Tests', () {
    test('Stores and streams received hazard maps', () async {
      final packetSubject = PublishSubject<MeshPacket>();
      when(() => mockMesh.incomingPackets).thenAnswer((_) => packetSubject.stream);
      
      final service = IntelligenceServiceImpl(mockMesh, mockGateway, mockAi, mockSecurity);
      service.start();

      final polygonExpectation = expectLater(
        service.hazardPolygonsStream,
        emitsInOrder([
          isEmpty,
          isNotEmpty,
        ]),
      );

      packetSubject.add(MeshPacket(
        packetId: 'P1',
        senderId: 'GATEWAY',
        senderPublicKey: '',
        packetType: PacketType.hazardMap,
        payload: '{"type":"Feature"}',
        signature: '',
        timestamp: 0,
        ttl: 1,
        priority: PacketPriority.medium,
        latitude: 0,
        longitude: 0,
      ));

      await polygonExpectation;
      service.stop();
    });

    test('Streams neighbor count from mesh', () async {
      when(() => mockMesh.currentDevices).thenReturn([]);
      
      final service = IntelligenceServiceImpl(mockMesh, mockGateway, mockAi, mockSecurity);
      
      final countExpectation = expectLater(
        service.neighborCountStream,
        emitsInOrder([0]),
      );

      await countExpectation;
    });
   group('Seismic Monitoring Tests', () {
      test('Streams local G-force', () async {
        final service = IntelligenceServiceImpl(mockMesh, mockGateway, mockAi, mockSecurity);
        
        final gForceExpectation = expectLater(
          service.localGForceStream,
          emitsInOrder([0.0]),
        );

        await gForceExpectation;
      });
    });
  });
}
