import 'package:isar/isar.dart';

part 'identity.g.dart';

@collection
class Identity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String deviceId;
  
  final List<int> privateKeySeed; // Ed25519 seed

  Identity({
    required this.deviceId,
    required this.privateKeySeed,
  });
}
