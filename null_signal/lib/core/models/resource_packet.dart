import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'resource_packet.g.dart';

enum ResourceType {
  @JsonValue('OFFER')
  offer,
  @JsonValue('NEED')
  need,
}

@JsonSerializable()
class ResourceExchangePayload {
  final String resourceName;
  final String description;
  final ResourceType type;
  final int quantity;
  
  @enumerated
  final ResourceCategory category;

  ResourceExchangePayload({
    required this.resourceName,
    required this.description,
    required this.type,
    required this.quantity,
    required this.category,
  });

  factory ResourceExchangePayload.fromJson(Map<String, dynamic> json) => _$ResourceExchangePayloadFromJson(json);
  Map<String, dynamic> toJson() => _$ResourceExchangePayloadToJson(this);
}

enum ResourceCategory {
  medical,
  food,
  water,
  shelter,
  tools,
  power,
  other,
}
