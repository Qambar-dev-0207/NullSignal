// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mesh_packet.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMeshPacketCollection on Isar {
  IsarCollection<MeshPacket> get meshPackets => this.collection();
}

const MeshPacketSchema = CollectionSchema(
  name: r'MeshPacket',
  id: -5283217664943356984,
  properties: {
    r'isGatewayRelay': PropertySchema(
      id: 0,
      name: r'isGatewayRelay',
      type: IsarType.bool,
    ),
    r'latitude': PropertySchema(
      id: 1,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 2,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'packetId': PropertySchema(
      id: 3,
      name: r'packetId',
      type: IsarType.string,
    ),
    r'packetType': PropertySchema(
      id: 4,
      name: r'packetType',
      type: IsarType.byte,
      enumMap: _MeshPacketpacketTypeEnumValueMap,
    ),
    r'payload': PropertySchema(
      id: 5,
      name: r'payload',
      type: IsarType.string,
    ),
    r'priority': PropertySchema(
      id: 6,
      name: r'priority',
      type: IsarType.byte,
      enumMap: _MeshPacketpriorityEnumValueMap,
    ),
    r'receiverId': PropertySchema(
      id: 7,
      name: r'receiverId',
      type: IsarType.string,
    ),
    r'senderId': PropertySchema(
      id: 8,
      name: r'senderId',
      type: IsarType.string,
    ),
    r'senderPublicKey': PropertySchema(
      id: 9,
      name: r'senderPublicKey',
      type: IsarType.string,
    ),
    r'signature': PropertySchema(
      id: 10,
      name: r'signature',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 11,
      name: r'timestamp',
      type: IsarType.long,
    ),
    r'ttl': PropertySchema(
      id: 12,
      name: r'ttl',
      type: IsarType.long,
    )
  },
  estimateSize: _meshPacketEstimateSize,
  serialize: _meshPacketSerialize,
  deserialize: _meshPacketDeserialize,
  deserializeProp: _meshPacketDeserializeProp,
  idName: r'id',
  indexes: {
    r'packetId': IndexSchema(
      id: 3245725721812872481,
      name: r'packetId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'packetId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _meshPacketGetId,
  getLinks: _meshPacketGetLinks,
  attach: _meshPacketAttach,
  version: '3.1.0+1',
);

int _meshPacketEstimateSize(
  MeshPacket object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.packetId.length * 3;
  bytesCount += 3 + object.payload.length * 3;
  {
    final value = object.receiverId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.senderId.length * 3;
  bytesCount += 3 + object.senderPublicKey.length * 3;
  bytesCount += 3 + object.signature.length * 3;
  return bytesCount;
}

void _meshPacketSerialize(
  MeshPacket object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isGatewayRelay);
  writer.writeDouble(offsets[1], object.latitude);
  writer.writeDouble(offsets[2], object.longitude);
  writer.writeString(offsets[3], object.packetId);
  writer.writeByte(offsets[4], object.packetType.index);
  writer.writeString(offsets[5], object.payload);
  writer.writeByte(offsets[6], object.priority.index);
  writer.writeString(offsets[7], object.receiverId);
  writer.writeString(offsets[8], object.senderId);
  writer.writeString(offsets[9], object.senderPublicKey);
  writer.writeString(offsets[10], object.signature);
  writer.writeLong(offsets[11], object.timestamp);
  writer.writeLong(offsets[12], object.ttl);
}

MeshPacket _meshPacketDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MeshPacket(
    isGatewayRelay: reader.readBoolOrNull(offsets[0]) ?? false,
    latitude: reader.readDouble(offsets[1]),
    longitude: reader.readDouble(offsets[2]),
    packetId: reader.readString(offsets[3]),
    packetType:
        _MeshPacketpacketTypeValueEnumMap[reader.readByteOrNull(offsets[4])] ??
            PacketType.text,
    payload: reader.readString(offsets[5]),
    priority:
        _MeshPacketpriorityValueEnumMap[reader.readByteOrNull(offsets[6])] ??
            PacketPriority.low,
    receiverId: reader.readStringOrNull(offsets[7]),
    senderId: reader.readString(offsets[8]),
    senderPublicKey: reader.readString(offsets[9]),
    signature: reader.readString(offsets[10]),
    timestamp: reader.readLong(offsets[11]),
    ttl: reader.readLong(offsets[12]),
  );
  object.id = id;
  return object;
}

P _meshPacketDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (_MeshPacketpacketTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          PacketType.text) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (_MeshPacketpriorityValueEnumMap[reader.readByteOrNull(offset)] ??
          PacketPriority.low) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MeshPacketpacketTypeEnumValueMap = {
  'text': 0,
  'sos': 1,
  'hazardMap': 2,
  'crowdAlert': 3,
  'seismicEvent': 4,
  'resourceExchange': 5,
};
const _MeshPacketpacketTypeValueEnumMap = {
  0: PacketType.text,
  1: PacketType.sos,
  2: PacketType.hazardMap,
  3: PacketType.crowdAlert,
  4: PacketType.seismicEvent,
  5: PacketType.resourceExchange,
};
const _MeshPacketpriorityEnumValueMap = {
  'low': 0,
  'medium': 1,
  'high': 2,
  'critical': 3,
};
const _MeshPacketpriorityValueEnumMap = {
  0: PacketPriority.low,
  1: PacketPriority.medium,
  2: PacketPriority.high,
  3: PacketPriority.critical,
};

Id _meshPacketGetId(MeshPacket object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _meshPacketGetLinks(MeshPacket object) {
  return [];
}

void _meshPacketAttach(IsarCollection<dynamic> col, Id id, MeshPacket object) {
  object.id = id;
}

extension MeshPacketByIndex on IsarCollection<MeshPacket> {
  Future<MeshPacket?> getByPacketId(String packetId) {
    return getByIndex(r'packetId', [packetId]);
  }

  MeshPacket? getByPacketIdSync(String packetId) {
    return getByIndexSync(r'packetId', [packetId]);
  }

  Future<bool> deleteByPacketId(String packetId) {
    return deleteByIndex(r'packetId', [packetId]);
  }

  bool deleteByPacketIdSync(String packetId) {
    return deleteByIndexSync(r'packetId', [packetId]);
  }

  Future<List<MeshPacket?>> getAllByPacketId(List<String> packetIdValues) {
    final values = packetIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'packetId', values);
  }

  List<MeshPacket?> getAllByPacketIdSync(List<String> packetIdValues) {
    final values = packetIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'packetId', values);
  }

  Future<int> deleteAllByPacketId(List<String> packetIdValues) {
    final values = packetIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'packetId', values);
  }

  int deleteAllByPacketIdSync(List<String> packetIdValues) {
    final values = packetIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'packetId', values);
  }

  Future<Id> putByPacketId(MeshPacket object) {
    return putByIndex(r'packetId', object);
  }

  Id putByPacketIdSync(MeshPacket object, {bool saveLinks = true}) {
    return putByIndexSync(r'packetId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPacketId(List<MeshPacket> objects) {
    return putAllByIndex(r'packetId', objects);
  }

  List<Id> putAllByPacketIdSync(List<MeshPacket> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'packetId', objects, saveLinks: saveLinks);
  }
}

extension MeshPacketQueryWhereSort
    on QueryBuilder<MeshPacket, MeshPacket, QWhere> {
  QueryBuilder<MeshPacket, MeshPacket, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MeshPacketQueryWhere
    on QueryBuilder<MeshPacket, MeshPacket, QWhereClause> {
  QueryBuilder<MeshPacket, MeshPacket, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterWhereClause> packetIdEqualTo(
      String packetId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'packetId',
        value: [packetId],
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterWhereClause> packetIdNotEqualTo(
      String packetId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packetId',
              lower: [],
              upper: [packetId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packetId',
              lower: [packetId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packetId',
              lower: [packetId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packetId',
              lower: [],
              upper: [packetId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MeshPacketQueryFilter
    on QueryBuilder<MeshPacket, MeshPacket, QFilterCondition> {
  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      isGatewayRelayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isGatewayRelay',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> packetIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      packetIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> packetIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> packetIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'packetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      packetIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> packetIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> packetIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> packetIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'packetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      packetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packetId',
        value: '',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      packetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'packetId',
        value: '',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> packetTypeEqualTo(
      PacketType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packetType',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      packetTypeGreaterThan(
    PacketType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'packetType',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      packetTypeLessThan(
    PacketType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'packetType',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> packetTypeBetween(
    PacketType lower,
    PacketType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'packetType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> payloadEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      payloadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> payloadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> payloadBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payload',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> payloadStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> payloadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> payloadContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> payloadMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'payload',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: '',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'payload',
        value: '',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> priorityEqualTo(
      PacketPriority value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      priorityGreaterThan(
    PacketPriority value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> priorityLessThan(
    PacketPriority value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> priorityBetween(
    PacketPriority lower,
    PacketPriority upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      receiverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'receiverId',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      receiverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'receiverId',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> receiverIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      receiverIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receiverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      receiverIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receiverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> receiverIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receiverId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      receiverIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'receiverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      receiverIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'receiverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      receiverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'receiverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> receiverIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'receiverId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      receiverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiverId',
        value: '',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      receiverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'receiverId',
        value: '',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> senderIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> senderIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> senderIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> senderIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> senderIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> senderIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderPublicKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderPublicKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderPublicKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderPublicKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderPublicKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderPublicKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderPublicKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderPublicKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderPublicKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderPublicKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderPublicKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderPublicKey',
        value: '',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      senderPublicKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderPublicKey',
        value: '',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> signatureEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      signatureGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> signatureLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> signatureBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'signature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      signatureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> signatureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> signatureContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> signatureMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'signature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      signatureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signature',
        value: '',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      signatureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'signature',
        value: '',
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> timestampEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition>
      timestampGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> timestampLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> timestampBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> ttlEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ttl',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> ttlGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ttl',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> ttlLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ttl',
        value: value,
      ));
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterFilterCondition> ttlBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ttl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MeshPacketQueryObject
    on QueryBuilder<MeshPacket, MeshPacket, QFilterCondition> {}

extension MeshPacketQueryLinks
    on QueryBuilder<MeshPacket, MeshPacket, QFilterCondition> {}

extension MeshPacketQuerySortBy
    on QueryBuilder<MeshPacket, MeshPacket, QSortBy> {
  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByIsGatewayRelay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGatewayRelay', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy>
      sortByIsGatewayRelayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGatewayRelay', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByPacketId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetId', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByPacketIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetId', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByPacketType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetType', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByPacketTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetType', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByReceiverId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiverId', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByReceiverIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiverId', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortBySenderPublicKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderPublicKey', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy>
      sortBySenderPublicKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderPublicKey', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByTtl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttl', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> sortByTtlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttl', Sort.desc);
    });
  }
}

extension MeshPacketQuerySortThenBy
    on QueryBuilder<MeshPacket, MeshPacket, QSortThenBy> {
  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByIsGatewayRelay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGatewayRelay', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy>
      thenByIsGatewayRelayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGatewayRelay', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByPacketId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetId', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByPacketIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetId', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByPacketType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetType', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByPacketTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetType', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByReceiverId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiverId', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByReceiverIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiverId', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenBySenderPublicKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderPublicKey', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy>
      thenBySenderPublicKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderPublicKey', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByTtl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttl', Sort.asc);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QAfterSortBy> thenByTtlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttl', Sort.desc);
    });
  }
}

extension MeshPacketQueryWhereDistinct
    on QueryBuilder<MeshPacket, MeshPacket, QDistinct> {
  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctByIsGatewayRelay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isGatewayRelay');
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctByPacketId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctByPacketType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packetType');
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctByPayload(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctByReceiverId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctBySenderId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctBySenderPublicKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderPublicKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctBySignature(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signature', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<MeshPacket, MeshPacket, QDistinct> distinctByTtl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ttl');
    });
  }
}

extension MeshPacketQueryProperty
    on QueryBuilder<MeshPacket, MeshPacket, QQueryProperty> {
  QueryBuilder<MeshPacket, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MeshPacket, bool, QQueryOperations> isGatewayRelayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isGatewayRelay');
    });
  }

  QueryBuilder<MeshPacket, double, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<MeshPacket, double, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<MeshPacket, String, QQueryOperations> packetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packetId');
    });
  }

  QueryBuilder<MeshPacket, PacketType, QQueryOperations> packetTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packetType');
    });
  }

  QueryBuilder<MeshPacket, String, QQueryOperations> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<MeshPacket, PacketPriority, QQueryOperations>
      priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<MeshPacket, String?, QQueryOperations> receiverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiverId');
    });
  }

  QueryBuilder<MeshPacket, String, QQueryOperations> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<MeshPacket, String, QQueryOperations> senderPublicKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderPublicKey');
    });
  }

  QueryBuilder<MeshPacket, String, QQueryOperations> signatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signature');
    });
  }

  QueryBuilder<MeshPacket, int, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<MeshPacket, int, QQueryOperations> ttlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ttl');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeshPacket _$MeshPacketFromJson(Map<String, dynamic> json) => MeshPacket(
      packetId: json['packetId'] as String,
      senderId: json['senderId'] as String,
      senderPublicKey: json['senderPublicKey'] as String,
      receiverId: json['receiverId'] as String?,
      packetType:
          $enumDecodeNullable(_$PacketTypeEnumMap, json['packetType']) ??
              PacketType.text,
      payload: json['payload'] as String,
      signature: json['signature'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      ttl: (json['ttl'] as num).toInt(),
      priority: $enumDecode(_$PacketPriorityEnumMap, json['priority']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isGatewayRelay: json['isGatewayRelay'] as bool? ?? false,
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$MeshPacketToJson(MeshPacket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'packetId': instance.packetId,
      'senderId': instance.senderId,
      'senderPublicKey': instance.senderPublicKey,
      'receiverId': instance.receiverId,
      'packetType': _$PacketTypeEnumMap[instance.packetType]!,
      'payload': instance.payload,
      'signature': instance.signature,
      'timestamp': instance.timestamp,
      'ttl': instance.ttl,
      'priority': _$PacketPriorityEnumMap[instance.priority]!,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isGatewayRelay': instance.isGatewayRelay,
    };

const _$PacketTypeEnumMap = {
  PacketType.text: 'TEXT',
  PacketType.sos: 'SOS',
  PacketType.hazardMap: 'HAZARD_MAP',
  PacketType.crowdAlert: 'CROWD_ALERT',
  PacketType.seismicEvent: 'SEISMIC_EVENT',
  PacketType.resourceExchange: 'RESOURCE_EXCHANGE',
};

const _$PacketPriorityEnumMap = {
  PacketPriority.low: 0,
  PacketPriority.medium: 1,
  PacketPriority.high: 2,
  PacketPriority.critical: 3,
};
