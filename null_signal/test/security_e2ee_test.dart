import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:cryptography/cryptography.dart';
import 'package:isar/isar.dart';
import 'package:null_signal/core/models/identity.dart';

void main() {
  late SecurityService securityService;
  late Isar isar;
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_security_test');
    isar = await Isar.open(
      [IdentitySchema],
      directory: tempDir.path,
    );
    securityService = SecurityService(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('SecurityService E2EE & Signatures', () {
    test('Signature Verification: Valid signature returns true', () async {
      final keyPair = await securityService.generateIdentity();
      final publicKey = await keyPair.extractPublicKey();
      const message = "Test Message";
      
      final signature = await securityService.sign(message, keyPair);
      final isValid = await securityService.verify(message, signature, publicKey);
      
      expect(isValid, isTrue);
    });

    test('Signature Verification: Invalid message returns false', () async {
      final keyPair = await securityService.generateIdentity();
      final publicKey = await keyPair.extractPublicKey();
      const message = "Test Message";
      
      final signature = await securityService.sign(message, keyPair);
      final isValid = await securityService.verify("Wrong Message", signature, publicKey);
      
      expect(isValid, isFalse);
    });

    test('E2EE: Derive shared secret and decrypt successfully', () async {
      // Setup Alice and Bob
      final aliceEncKeyPair = await securityService.newEncryptionKeyPair(); // X25519 for E2EE
      final bobEncKeyPair = await securityService.newEncryptionKeyPair();
      
      final alicePub = await aliceEncKeyPair.extractPublicKey();
      final bobPub = await bobEncKeyPair.extractPublicKey();

      // Derive shared secrets
      final aliceShared = await securityService.deriveSharedSecret(aliceEncKeyPair, bobPub);
      final bobShared = await securityService.deriveSharedSecret(bobEncKeyPair, alicePub);

      // Verify they derived the same secret
      final aliceKeyBytes = await aliceShared.extractBytes();
      final bobKeyBytes = await bobShared.extractBytes();
      expect(aliceKeyBytes, equals(bobKeyBytes));

      // Alice encrypts for Bob
      const secretMessage = "Secret Data";
      final encrypted = await securityService.encryptE2E(secretMessage, aliceShared);
      
      // Bob decrypts Alice's message
      final decrypted = await securityService.decryptE2E(encrypted, bobShared);
      expect(decrypted, equals(secretMessage));
    });
  });

  group('SecurityService Identity Persistence', () {
    test('getOrCreateIdentity: Creates new identity when none exists', () async {
      final identity = await securityService.getOrCreateIdentity();
      expect(identity, isNotNull);
      expect(securityService.deviceId, startsWith('Node_'));
      
      // Verify persistence
      final stored = await isar.identitys.where().findFirst();
      expect(stored, isNotNull);
      expect(stored?.deviceId, equals(securityService.deviceId));
    });

    test('getOrCreateIdentity: Returns existing identity when found', () async {
      // Manually create one
      final seed = await Ed25519().newKeyPair();
      final privateKey = await seed.extractPrivateKeyBytes();
      final existing = Identity(deviceId: 'Node_existing', privateKeySeed: privateKey);
      
      await isar.writeTxn(() => isar.identitys.put(existing));

      final identity = await securityService.getOrCreateIdentity();
      expect(identity, isNotNull);
      expect(securityService.deviceId, equals('Node_existing'));
    });
  });
}
