import 'package:isar/isar.dart';

part 'peer.g.dart';

@collection
class Peer {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String deviceId;
  
  final String deviceName;
  
  final String? publicKey; // Base64 Ed25519 public key
  
  final int lastSeen;

  Peer({
    required this.deviceId,
    required this.deviceName,
    this.publicKey,
    required this.lastSeen,
  });

  Peer copyWith({
    String? deviceName,
    String? publicKey,
    int? lastSeen,
  }) {
    return Peer(
      deviceId: deviceId,
      deviceName: deviceName ?? this.deviceName,
      publicKey: publicKey ?? this.publicKey,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
