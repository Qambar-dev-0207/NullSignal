import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:null_signal/features/mesh/presentation/bloc/mesh_cubit.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:null_signal/features/mesh/domain/entities/mesh_device.dart';
import 'package:cryptography/cryptography.dart';
import 'dart:convert';

class MockMeshService extends Mock implements MeshService {}
class MockSecurityService extends Mock implements SecurityService {}
class MockKeyPair extends Mock implements KeyPair {}
class MockSecretKey extends Mock implements SecretKey {}
class FakeKeyPair extends Fake implements KeyPair {}
class FakeSecretKey extends Fake implements SecretKey {}

void main() {
  late MeshCubit meshCubit;
  late MockMeshService mockMeshService;
  late MockSecurityService mockSecurityService;
  const deviceId = 'test_device';

  setUpAll(() {
    registerFallbackValue(FakeKeyPair());
    registerFallbackValue(FakeSecretKey());
    registerFallbackValue(SimplePublicKey([], type: KeyPairType.ed25519));
    registerFallbackValue(MeshPacket(
      packetId: 'dummy',
      senderId: 'dummy',
      senderPublicKey: 'dummy',
      payload: 'dummy',
      signature: 'dummy',
      timestamp: 0,
      ttl: 0,
      priority: PacketPriority.low,
      latitude: 0,
      longitude: 0,
    ));
  });

  setUp(() {
    mockMeshService = MockMeshService();
    mockSecurityService = MockSecurityService();
    meshCubit = MeshCubit(mockMeshService, mockSecurityService, deviceId);
  });

  tearDown(() {
    meshCubit.close();
  });

  group('MeshCubit Tests', () {
    test('Initial state is correct', () {
      expect(meshCubit.state.connectedDevices, isEmpty);
      expect(meshCubit.state.scannedDevices, isEmpty);
      expect(meshCubit.state.isScanning, isFalse);
    });

    test('sendDirectMessage uses E2EE when public key is present', () async {
      final mockKeyPair = MockKeyPair();
      final mockSecretKey = MockSecretKey();
      final myPublicKey = SimplePublicKey([1], type: KeyPairType.ed25519);
      final recipientPublicKey = base64.encode([2, 3, 4]);
      
      final device = MeshDevice(
        deviceId: 'recipient',
        deviceName: 'Recipient',
        status: MeshDeviceStatus.connected,
        publicKey: recipientPublicKey,
      );

      when(() => mockSecurityService.getOrCreateIdentity()).thenAnswer((_) async => mockKeyPair);
      when(() => mockKeyPair.extractPublicKey()).thenAnswer((_) async => myPublicKey);
      when(() => mockSecurityService.deriveSharedSecret(any(), any())).thenAnswer((_) async => mockSecretKey);
      when(() => mockSecurityService.encryptE2E(any(), any())).thenAnswer((_) async => 'encrypted_payload');
      when(() => mockSecurityService.sign(any(), any())).thenAnswer((_) async => 'signature');
      when(() => mockMeshService.sendPacket(any())).thenAnswer((_) async => {});

      await meshCubit.sendDirectMessage(device, 'Hello');

      verify(() => mockSecurityService.deriveSharedSecret(any(), any())).called(1);
      verify(() => mockSecurityService.encryptE2E(any(), any())).called(1);
      verify(() => mockMeshService.sendPacket(any())).called(1);
    });

    test('sendDirectMessage sends cleartext when public key is missing', () async {
      final mockKeyPair = MockKeyPair();
      final myPublicKey = SimplePublicKey([1], type: KeyPairType.ed25519);
      
      final device = MeshDevice(
        deviceId: 'recipient',
        deviceName: 'Recipient',
        status: MeshDeviceStatus.connected,
        publicKey: null,
      );

      when(() => mockSecurityService.getOrCreateIdentity()).thenAnswer((_) async => mockKeyPair);
      when(() => mockKeyPair.extractPublicKey()).thenAnswer((_) async => myPublicKey);
      when(() => mockSecurityService.sign(any(), any())).thenAnswer((_) async => 'signature');
      when(() => mockMeshService.sendPacket(any())).thenAnswer((_) async => {});

      await meshCubit.sendDirectMessage(device, 'Hello');

      verifyNever(() => mockSecurityService.deriveSharedSecret(any(), any()));
      verifyNever(() => mockSecurityService.encryptE2E(any(), any()));
      verify(() => mockMeshService.sendPacket(any())).called(1);
    });
  });
}
