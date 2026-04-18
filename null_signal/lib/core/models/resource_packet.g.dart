// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_packet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceExchangePayload _$ResourceExchangePayloadFromJson(
        Map<String, dynamic> json) =>
    ResourceExchangePayload(
      resourceName: json['resourceName'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ResourceTypeEnumMap, json['type']),
      quantity: (json['quantity'] as num).toInt(),
      category: $enumDecode(_$ResourceCategoryEnumMap, json['category']),
    );

Map<String, dynamic> _$ResourceExchangePayloadToJson(
        ResourceExchangePayload instance) =>
    <String, dynamic>{
      'resourceName': instance.resourceName,
      'description': instance.description,
      'type': _$ResourceTypeEnumMap[instance.type]!,
      'quantity': instance.quantity,
      'category': _$ResourceCategoryEnumMap[instance.category]!,
    };

const _$ResourceTypeEnumMap = {
  ResourceType.offer: 'OFFER',
  ResourceType.need: 'NEED',
};

const _$ResourceCategoryEnumMap = {
  ResourceCategory.medical: 'medical',
  ResourceCategory.food: 'food',
  ResourceCategory.water: 'water',
  ResourceCategory.shelter: 'shelter',
  ResourceCategory.tools: 'tools',
  ResourceCategory.power: 'power',
  ResourceCategory.other: 'other',
};
