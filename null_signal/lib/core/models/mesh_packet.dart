import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mesh_packet.g.dart';

enum PacketPriority {
  @JsonValue(0)
  low,
  @JsonValue(1)
  medium,
  @JsonValue(2)
  high,
  @JsonValue(3)
  critical, // SOS
}

enum PacketType {
  @JsonValue('TEXT')
  text,
  @JsonValue('SOS')
  sos,
  @JsonValue('HAZARD_MAP')
  hazardMap,
  @JsonValue('CROWD_ALERT')
  crowdAlert,
  @JsonValue('SEISMIC_EVENT')
  seismicEvent,
  @JsonValue('RESOURCE_EXCHANGE')
  resourceExchange,
}

@collection
@JsonSerializable()
class MeshPacket {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String packetId;
  
  final String senderId;
  final String senderPublicKey;
  final String? receiverId; // Null for broadcast
  
  @enumerated
  final PacketType packetType;
  
  final String payload; // Encrypted AES-256 or GeoJSON/Telemetry
  final String signature; // ECDSA signature
  
  final int timestamp;
  final int ttl; // Time To Live (hops)
  
  @enumerated
  final PacketPriority priority;
  
  final double latitude;
  final double longitude;
  
  final bool isGatewayRelay; // True if intended for internet escalation

  MeshPacket({
    required this.packetId,
    required this.senderId,
    required this.senderPublicKey,
    this.receiverId,
    this.packetType = PacketType.text,
    required this.payload,
    required this.signature,
    required this.timestamp,
    required this.ttl,
    required this.priority,
    required this.latitude,
    required this.longitude,
    this.isGatewayRelay = false,
  });

  factory MeshPacket.fromJson(Map<String, dynamic> json) => _$MeshPacketFromJson(json);
  Map<String, dynamic> toJson() => _$MeshPacketToJson(this);
}
