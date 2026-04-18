// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sector_summary.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSectorSummaryCollection on Isar {
  IsarCollection<SectorSummary> get sectorSummarys => this.collection();
}

const SectorSummarySchema = CollectionSchema(
  name: r'SectorSummary',
  id: 7942975168023749668,
  properties: {
    r'centerLatitude': PropertySchema(
      id: 0,
      name: r'centerLatitude',
      type: IsarType.double,
    ),
    r'centerLongitude': PropertySchema(
      id: 1,
      name: r'centerLongitude',
      type: IsarType.double,
    ),
    r'radius': PropertySchema(
      id: 2,
      name: r'radius',
      type: IsarType.double,
    ),
    r'sectorId': PropertySchema(
      id: 3,
      name: r'sectorId',
      type: IsarType.string,
    ),
    r'summary': PropertySchema(
      id: 4,
      name: r'summary',
      type: IsarType.string,
    ),
    r'survivorCount': PropertySchema(
      id: 5,
      name: r'survivorCount',
      type: IsarType.long,
    ),
    r'timestamp': PropertySchema(
      id: 6,
      name: r'timestamp',
      type: IsarType.long,
    ),
    r'urgentNeeds': PropertySchema(
      id: 7,
      name: r'urgentNeeds',
      type: IsarType.stringList,
    )
  },
  estimateSize: _sectorSummaryEstimateSize,
  serialize: _sectorSummarySerialize,
  deserialize: _sectorSummaryDeserialize,
  deserializeProp: _sectorSummaryDeserializeProp,
  idName: r'id',
  indexes: {
    r'sectorId': IndexSchema(
      id: 1119158776821935563,
      name: r'sectorId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sectorId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _sectorSummaryGetId,
  getLinks: _sectorSummaryGetLinks,
  attach: _sectorSummaryAttach,
  version: '3.1.0+1',
);

int _sectorSummaryEstimateSize(
  SectorSummary object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.sectorId.length * 3;
  bytesCount += 3 + object.summary.length * 3;
  bytesCount += 3 + object.urgentNeeds.length * 3;
  {
    for (var i = 0; i < object.urgentNeeds.length; i++) {
      final value = object.urgentNeeds[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _sectorSummarySerialize(
  SectorSummary object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.centerLatitude);
  writer.writeDouble(offsets[1], object.centerLongitude);
  writer.writeDouble(offsets[2], object.radius);
  writer.writeString(offsets[3], object.sectorId);
  writer.writeString(offsets[4], object.summary);
  writer.writeLong(offsets[5], object.survivorCount);
  writer.writeLong(offsets[6], object.timestamp);
  writer.writeStringList(offsets[7], object.urgentNeeds);
}

SectorSummary _sectorSummaryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SectorSummary(
    centerLatitude: reader.readDouble(offsets[0]),
    centerLongitude: reader.readDouble(offsets[1]),
    radius: reader.readDouble(offsets[2]),
    sectorId: reader.readString(offsets[3]),
    summary: reader.readString(offsets[4]),
    survivorCount: reader.readLong(offsets[5]),
    timestamp: reader.readLong(offsets[6]),
    urgentNeeds: reader.readStringList(offsets[7]) ?? [],
  );
  object.id = id;
  return object;
}

P _sectorSummaryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sectorSummaryGetId(SectorSummary object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sectorSummaryGetLinks(SectorSummary object) {
  return [];
}

void _sectorSummaryAttach(
    IsarCollection<dynamic> col, Id id, SectorSummary object) {
  object.id = id;
}

extension SectorSummaryByIndex on IsarCollection<SectorSummary> {
  Future<SectorSummary?> getBySectorId(String sectorId) {
    return getByIndex(r'sectorId', [sectorId]);
  }

  SectorSummary? getBySectorIdSync(String sectorId) {
    return getByIndexSync(r'sectorId', [sectorId]);
  }

  Future<bool> deleteBySectorId(String sectorId) {
    return deleteByIndex(r'sectorId', [sectorId]);
  }

  bool deleteBySectorIdSync(String sectorId) {
    return deleteByIndexSync(r'sectorId', [sectorId]);
  }

  Future<List<SectorSummary?>> getAllBySectorId(List<String> sectorIdValues) {
    final values = sectorIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sectorId', values);
  }

  List<SectorSummary?> getAllBySectorIdSync(List<String> sectorIdValues) {
    final values = sectorIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sectorId', values);
  }

  Future<int> deleteAllBySectorId(List<String> sectorIdValues) {
    final values = sectorIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sectorId', values);
  }

  int deleteAllBySectorIdSync(List<String> sectorIdValues) {
    final values = sectorIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sectorId', values);
  }

  Future<Id> putBySectorId(SectorSummary object) {
    return putByIndex(r'sectorId', object);
  }

  Id putBySectorIdSync(SectorSummary object, {bool saveLinks = true}) {
    return putByIndexSync(r'sectorId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySectorId(List<SectorSummary> objects) {
    return putAllByIndex(r'sectorId', objects);
  }

  List<Id> putAllBySectorIdSync(List<SectorSummary> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sectorId', objects, saveLinks: saveLinks);
  }
}

extension SectorSummaryQueryWhereSort
    on QueryBuilder<SectorSummary, SectorSummary, QWhere> {
  QueryBuilder<SectorSummary, SectorSummary, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SectorSummaryQueryWhere
    on QueryBuilder<SectorSummary, SectorSummary, QWhereClause> {
  QueryBuilder<SectorSummary, SectorSummary, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SectorSummary, SectorSummary, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterWhereClause> idBetween(
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

  QueryBuilder<SectorSummary, SectorSummary, QAfterWhereClause> sectorIdEqualTo(
      String sectorId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sectorId',
        value: [sectorId],
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterWhereClause>
      sectorIdNotEqualTo(String sectorId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sectorId',
              lower: [],
              upper: [sectorId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sectorId',
              lower: [sectorId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sectorId',
              lower: [sectorId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sectorId',
              lower: [],
              upper: [sectorId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SectorSummaryQueryFilter
    on QueryBuilder<SectorSummary, SectorSummary, QFilterCondition> {
  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      centerLatitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'centerLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      centerLatitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'centerLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      centerLatitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'centerLatitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      centerLatitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'centerLatitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      centerLongitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'centerLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      centerLongitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'centerLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      centerLongitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'centerLongitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      centerLongitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'centerLongitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      radiusEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'radius',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      radiusGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'radius',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      radiusLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'radius',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      radiusBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'radius',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      sectorIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sectorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      sectorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sectorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      sectorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sectorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      sectorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sectorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      sectorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sectorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      sectorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sectorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      sectorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sectorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      sectorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sectorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      sectorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sectorId',
        value: '',
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      sectorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sectorId',
        value: '',
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      summaryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      summaryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      summaryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      summaryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'summary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      summaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      summaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      summaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      summaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'summary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      summaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summary',
        value: '',
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      summaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'summary',
        value: '',
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      survivorCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'survivorCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      survivorCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'survivorCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      survivorCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'survivorCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      survivorCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'survivorCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      timestampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
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

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      timestampLessThan(
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

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      timestampBetween(
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

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urgentNeeds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'urgentNeeds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'urgentNeeds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'urgentNeeds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'urgentNeeds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'urgentNeeds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'urgentNeeds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'urgentNeeds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urgentNeeds',
        value: '',
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'urgentNeeds',
        value: '',
      ));
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'urgentNeeds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'urgentNeeds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'urgentNeeds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'urgentNeeds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'urgentNeeds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterFilterCondition>
      urgentNeedsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'urgentNeeds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension SectorSummaryQueryObject
    on QueryBuilder<SectorSummary, SectorSummary, QFilterCondition> {}

extension SectorSummaryQueryLinks
    on QueryBuilder<SectorSummary, SectorSummary, QFilterCondition> {}

extension SectorSummaryQuerySortBy
    on QueryBuilder<SectorSummary, SectorSummary, QSortBy> {
  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      sortByCenterLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'centerLatitude', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      sortByCenterLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'centerLatitude', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      sortByCenterLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'centerLongitude', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      sortByCenterLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'centerLongitude', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> sortByRadius() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'radius', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> sortByRadiusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'radius', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> sortBySectorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectorId', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      sortBySectorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectorId', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> sortBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> sortBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      sortBySurvivorCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'survivorCount', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      sortBySurvivorCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'survivorCount', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension SectorSummaryQuerySortThenBy
    on QueryBuilder<SectorSummary, SectorSummary, QSortThenBy> {
  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      thenByCenterLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'centerLatitude', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      thenByCenterLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'centerLatitude', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      thenByCenterLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'centerLongitude', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      thenByCenterLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'centerLongitude', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> thenByRadius() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'radius', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> thenByRadiusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'radius', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> thenBySectorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectorId', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      thenBySectorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectorId', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> thenBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> thenBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      thenBySurvivorCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'survivorCount', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      thenBySurvivorCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'survivorCount', Sort.desc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension SectorSummaryQueryWhereDistinct
    on QueryBuilder<SectorSummary, SectorSummary, QDistinct> {
  QueryBuilder<SectorSummary, SectorSummary, QDistinct>
      distinctByCenterLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'centerLatitude');
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QDistinct>
      distinctByCenterLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'centerLongitude');
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QDistinct> distinctByRadius() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'radius');
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QDistinct> distinctBySectorId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sectorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QDistinct> distinctBySummary(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'summary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QDistinct>
      distinctBySurvivorCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'survivorCount');
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<SectorSummary, SectorSummary, QDistinct>
      distinctByUrgentNeeds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'urgentNeeds');
    });
  }
}

extension SectorSummaryQueryProperty
    on QueryBuilder<SectorSummary, SectorSummary, QQueryProperty> {
  QueryBuilder<SectorSummary, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SectorSummary, double, QQueryOperations>
      centerLatitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'centerLatitude');
    });
  }

  QueryBuilder<SectorSummary, double, QQueryOperations>
      centerLongitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'centerLongitude');
    });
  }

  QueryBuilder<SectorSummary, double, QQueryOperations> radiusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'radius');
    });
  }

  QueryBuilder<SectorSummary, String, QQueryOperations> sectorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sectorId');
    });
  }

  QueryBuilder<SectorSummary, String, QQueryOperations> summaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'summary');
    });
  }

  QueryBuilder<SectorSummary, int, QQueryOperations> survivorCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'survivorCount');
    });
  }

  QueryBuilder<SectorSummary, int, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<SectorSummary, List<String>, QQueryOperations>
      urgentNeedsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'urgentNeeds');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SectorSummary _$SectorSummaryFromJson(Map<String, dynamic> json) =>
    SectorSummary(
      sectorId: json['sectorId'] as String,
      summary: json['summary'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      centerLatitude: (json['centerLatitude'] as num).toDouble(),
      centerLongitude: (json['centerLongitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      survivorCount: (json['survivorCount'] as num).toInt(),
      urgentNeeds: (json['urgentNeeds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$SectorSummaryToJson(SectorSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sectorId': instance.sectorId,
      'summary': instance.summary,
      'timestamp': instance.timestamp,
      'centerLatitude': instance.centerLatitude,
      'centerLongitude': instance.centerLongitude,
      'radius': instance.radius,
      'survivorCount': instance.survivorCount,
      'urgentNeeds': instance.urgentNeeds,
    };
