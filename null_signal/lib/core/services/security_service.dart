import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class SecurityService {
  final _aes = AesGcm.with256bits();
  final _signatureAlgorithm = Ed25519();

  /// Generates a new identity for the device
  Future<KeyPair> generateIdentity() async {
    return await _signatureAlgorithm.newKeyPair();
  }

  /// Encrypts a payload for the mesh
  Future<String> encrypt(String payload, SecretKey secretKey) async {
    final clearText = utf8.encode(payload);
    final secretBox = await _aes.encrypt(clearText, secretKey: secretKey);
    return base64.encode(secretBox.concatenation());
  }

  /// Decrypts a mesh payload
  Future<String> decrypt(String base64Payload, SecretKey secretKey) async {
    final combined = base64.decode(base64Payload);
    final secretBox = SecretBox.fromConcatenation(
      combined,
      nonceLength: _aes.nonceLength,
      macLength: _aes.macAlgorithm.macLength,
    );
    final clearText = await _aes.decrypt(secretBox, secretKey: secretKey);
    return utf8.decode(clearText);
  }

  /// Signs data to ensure integrity
  Future<String> sign(String data, KeyPair keyPair) async {
    final bytes = utf8.encode(data);
    final signature = await _signatureAlgorithm.sign(bytes, keyPair: keyPair);
    return base64.encode(signature.bytes);
  }

  /// Verifies a packet's signature
  Future<bool> verify(String data, String base64Signature, PublicKey publicKey) async {
    final bytes = utf8.encode(data);
    final signatureBytes = base64.decode(base64Signature);
    final signature = Signature(signatureBytes, publicKey: publicKey);
    return await _signatureAlgorithm.verify(bytes, signature: signature);
  }
}
