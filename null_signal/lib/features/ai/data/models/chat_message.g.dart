// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChatMessageCollection on Isar {
  IsarCollection<ChatMessage> get chatMessages => this.collection();
}

const ChatMessageSchema = CollectionSchema(
  name: r'ChatMessage',
  id: 35366979330584919,
  properties: {
    r'content': PropertySchema(
      id: 0,
      name: r'content',
      type: IsarType.string,
    ),
    r'isAI': PropertySchema(
      id: 1,
      name: r'isAI',
      type: IsarType.bool,
    ),
    r'senderId': PropertySchema(
      id: 2,
      name: r'senderId',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 3,
      name: r'timestamp',
      type: IsarType.long,
    )
  },
  estimateSize: _chatMessageEstimateSize,
  serialize: _chatMessageSerialize,
  deserialize: _chatMessageDeserialize,
  deserializeProp: _chatMessageDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _chatMessageGetId,
  getLinks: _chatMessageGetLinks,
  attach: _chatMessageAttach,
  version: '3.1.0+1',
);

int _chatMessageEstimateSize(
  ChatMessage object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.content.length * 3;
  bytesCount += 3 + object.senderId.length * 3;
  return bytesCount;
}

void _chatMessageSerialize(
  ChatMessage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.content);
  writer.writeBool(offsets[1], object.isAI);
  writer.writeString(offsets[2], object.senderId);
  writer.writeLong(offsets[3], object.timestamp);
}

ChatMessage _chatMessageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChatMessage(
    content: reader.readString(offsets[0]),
    isAI: reader.readBool(offsets[1]),
    senderId: reader.readString(offsets[2]),
    timestamp: reader.readLong(offsets[3]),
  );
  object.id = id;
  return object;
}

P _chatMessageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _chatMessageGetId(ChatMessage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _chatMessageGetLinks(ChatMessage object) {
  return [];
}

void _chatMessageAttach(
    IsarCollection<dynamic> col, Id id, ChatMessage object) {
  object.id = id;
}

extension ChatMessageQueryWhereSort
    on QueryBuilder<ChatMessage, ChatMessage, QWhere> {
  QueryBuilder<ChatMessage, ChatMessage, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChatMessageQueryWhere
    on QueryBuilder<ChatMessage, ChatMessage, QWhereClause> {
  QueryBuilder<ChatMessage, ChatMessage, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterWhereClause> idBetween(
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
}

extension ChatMessageQueryFilter
    on QueryBuilder<ChatMessage, ChatMessage, QFilterCondition> {
  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
      contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
      contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> contentContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> contentMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> isAIEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAI',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> senderIdEqualTo(
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
      senderIdLessThan(
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> senderIdBetween(
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
      senderIdEndsWith(
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
      senderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition> senderIdMatches(
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
      senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
      senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
      timestampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
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

  QueryBuilder<ChatMessage, ChatMessage, QAfterFilterCondition>
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
}

extension ChatMessageQueryObject
    on QueryBuilder<ChatMessage, ChatMessage, QFilterCondition> {}

extension ChatMessageQueryLinks
    on QueryBuilder<ChatMessage, ChatMessage, QFilterCondition> {}

extension ChatMessageQuerySortBy
    on QueryBuilder<ChatMessage, ChatMessage, QSortBy> {
  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> sortByIsAI() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAI', Sort.asc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> sortByIsAIDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAI', Sort.desc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ChatMessageQuerySortThenBy
    on QueryBuilder<ChatMessage, ChatMessage, QSortThenBy> {
  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> thenByIsAI() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAI', Sort.asc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> thenByIsAIDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAI', Sort.desc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ChatMessageQueryWhereDistinct
    on QueryBuilder<ChatMessage, ChatMessage, QDistinct> {
  QueryBuilder<ChatMessage, ChatMessage, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QDistinct> distinctByIsAI() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAI');
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QDistinct> distinctBySenderId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatMessage, ChatMessage, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension ChatMessageQueryProperty
    on QueryBuilder<ChatMessage, ChatMessage, QQueryProperty> {
  QueryBuilder<ChatMessage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChatMessage, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<ChatMessage, bool, QQueryOperations> isAIProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAI');
    });
  }

  QueryBuilder<ChatMessage, String, QQueryOperations> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<ChatMessage, int, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      isAI: json['isAI'] as bool,
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'content': instance.content,
      'timestamp': instance.timestamp,
      'isAI': instance.isAI,
    };
