import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:null_signal/features/sos/presentation/bloc/sos_cubit.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/core/models/mesh_packet.dart';
import 'package:cryptography/cryptography.dart';

class MockMeshService extends Mock implements MeshService {}
class MockSecurityService extends Mock implements SecurityService {}
class MockKeyPair extends Mock implements KeyPair {}
class FakeKeyPair extends Fake implements KeyPair {}
class MockPublicKey extends Mock implements PublicKey {}

void main() {
  late SosCubit sosCubit;
  late MockMeshService mockMeshService;
  late MockSecurityService mockSecurityService;
  const deviceId = 'test_device';

  setUpAll(() {
    registerFallbackValue(FakeKeyPair());
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
    sosCubit = SosCubit(mockMeshService, mockSecurityService, deviceId);
  });

  tearDown(() {
    sosCubit.close();
  });

  group('SosCubit Tests', () {
    test('Initial state is SosInitial', () {
      expect(sosCubit.state, isA<SosInitial>());
    });

    test('broadcastSos emits success when all services work', () async {
      final mockKeyPair = MockKeyPair();
      final mockPublicKey = SimplePublicKey([1, 2, 3], type: KeyPairType.ed25519);
      
      when(() => mockSecurityService.getOrCreateIdentity()).thenAnswer((_) async => mockKeyPair);
      when(() => mockKeyPair.extractPublicKey()).thenAnswer((_) async => mockPublicKey);
      when(() => mockSecurityService.sign(any(), any())).thenAnswer((_) async => 'mock_signature');
      when(() => mockMeshService.sendPacket(any())).thenAnswer((_) async => {});

      final expectation = expectLater(
        sosCubit.stream,
        emitsInOrder([
          isA<SosBroadcasting>(),
          isA<SosBroadcastSuccess>(),
        ]),
      );

      await sosCubit.broadcastSos(lat: 10.0, lon: 20.0);

      await expectation;
      verify(() => mockMeshService.sendPacket(any())).called(1);
    });

    test('broadcastSos emits error when service fails', () async {
      when(() => mockSecurityService.getOrCreateIdentity()).thenThrow(Exception('Key Error'));

      final expectation = expectLater(
        sosCubit.stream,
        emitsInOrder([
          isA<SosBroadcasting>(),
          isA<SosError>(),
        ]),
      );

      await sosCubit.broadcastSos(lat: 10.0, lon: 20.0);

      await expectation;
    });
  });
}
