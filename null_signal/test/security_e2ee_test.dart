import 'package:flutter_test/flutter_test.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:cryptography/cryptography.dart';
import 'dart:convert';

void main() {
  late SecurityService securityService;

  setUp(() {
    securityService = SecurityService();
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
}
