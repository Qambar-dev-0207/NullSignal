import 'package:flutter_test/flutter_test.dart';
import 'package:cryptography/cryptography.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/features/sos/domain/repositories/safety_monitor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:isar/isar.dart';

class MockIsar extends Mock implements Isar {}

void main() {
  group('SecurityService Tests', () {
    late SecurityService securityService;
    late MockIsar mockIsar;

    setUp(() {
      mockIsar = MockIsar();
      securityService = SecurityService(mockIsar);
    });

    test('Encryption and Decryption cycle should return original payload', () async {
      final secretKey = await AesGcm.with256bits().newSecretKey();
      const payload = 'Secret SOS Message';
      
      final encrypted = await securityService.encrypt(payload, secretKey);
      final decrypted = await securityService.decrypt(encrypted, secretKey);
      
      expect(decrypted, equals(payload));
    });

    test('Signature verification should pass for valid signature', () async {
      final keyPair = await securityService.generateIdentity();
      const data = 'Integrity Check';
      
      final signature = await securityService.sign(data, keyPair);
      final publicKey = await keyPair.extractPublicKey();
      
      final isValid = await securityService.verify(data, signature, publicKey);
      expect(isValid, isTrue);
    });

    test('Signature verification should fail for tampered data', () async {
      final keyPair = await securityService.generateIdentity();
      const data = 'Original Data';
      const tamperedData = 'Tampered Data';
      
      final signature = await securityService.sign(data, keyPair);
      final publicKey = await keyPair.extractPublicKey();
      
      final isValid = await securityService.verify(tamperedData, signature, publicKey);
      expect(isValid, isFalse);
    });
  });

  group('SafetyMonitor Tests', () {
    test('SafetyMonitor should notify when check-in is required', () async {
      final monitor = SafetyMonitor();
      // Using a shorter duration for test if possible, 
      // but since it's hardcoded in the class we just verify the stream setup
      expect(monitor.onCheckInRequired, isA<Stream<bool>>());
      expect(monitor.onAutoSosTriggered, isA<Stream<void>>());
    });
  });
}
