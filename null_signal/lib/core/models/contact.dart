import 'package:isar/isar.dart';

part 'contact.g.dart';

@collection
class Contact {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String deviceId;
  
  final String alias;
  
  final bool isFamily;
  
  final String? publicKey;

  Contact({
    required this.deviceId,
    required this.alias,
    this.isFamily = false,
    this.publicKey,
  });
}

@collection
class SeenPacket {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String packetId;
  
  final int timestamp;

  SeenPacket({
    required this.packetId,
    required this.timestamp,
  });
}
