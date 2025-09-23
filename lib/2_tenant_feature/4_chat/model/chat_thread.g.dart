// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_thread.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChatThreadCollection on Isar {
  IsarCollection<ChatThread> get chatThreads => this.collection();
}

const ChatThreadSchema = CollectionSchema(
  name: r'ChatThread',
  id: -7804860880153139966,
  properties: {
    r'id': PropertySchema(
      id: 0,
      name: r'id',
      type: IsarType.string,
    ),
    r'lastMessage': PropertySchema(
      id: 1,
      name: r'lastMessage',
      type: IsarType.string,
    ),
    r'lastMessageId': PropertySchema(
      id: 2,
      name: r'lastMessageId',
      type: IsarType.string,
    ),
    r'messageType': PropertySchema(
      id: 3,
      name: r'messageType',
      type: IsarType.string,
    ),
    r'timeStamp': PropertySchema(
      id: 4,
      name: r'timeStamp',
      type: IsarType.dateTime,
    ),
    r'unreadCountJson': PropertySchema(
      id: 5,
      name: r'unreadCountJson',
      type: IsarType.string,
    ),
    r'whoReceived': PropertySchema(
      id: 6,
      name: r'whoReceived',
      type: IsarType.string,
    ),
    r'whoSent': PropertySchema(
      id: 7,
      name: r'whoSent',
      type: IsarType.string,
    )
  },
  estimateSize: _chatThreadEstimateSize,
  serialize: _chatThreadSerialize,
  deserialize: _chatThreadDeserialize,
  deserializeProp: _chatThreadDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'whoSent': IndexSchema(
      id: -1478251415264109684,
      name: r'whoSent',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'whoSent',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'whoReceived': IndexSchema(
      id: 5236519281694465316,
      name: r'whoReceived',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'whoReceived',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _chatThreadGetId,
  getLinks: _chatThreadGetLinks,
  attach: _chatThreadAttach,
  version: '3.1.0+1',
);

int _chatThreadEstimateSize(
  ChatThread object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.lastMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastMessageId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.messageType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.unreadCountJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.whoReceived.length * 3;
  bytesCount += 3 + object.whoSent.length * 3;
  return bytesCount;
}

void _chatThreadSerialize(
  ChatThread object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.id);
  writer.writeString(offsets[1], object.lastMessage);
  writer.writeString(offsets[2], object.lastMessageId);
  writer.writeString(offsets[3], object.messageType);
  writer.writeDateTime(offsets[4], object.timeStamp);
  writer.writeString(offsets[5], object.unreadCountJson);
  writer.writeString(offsets[6], object.whoReceived);
  writer.writeString(offsets[7], object.whoSent);
}

ChatThread _chatThreadDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChatThread();
  object.id = reader.readString(offsets[0]);
  object.lastMessage = reader.readStringOrNull(offsets[1]);
  object.lastMessageId = reader.readStringOrNull(offsets[2]);
  object.messageType = reader.readStringOrNull(offsets[3]);
  object.timeStamp = reader.readDateTime(offsets[4]);
  object.unreadCountJson = reader.readStringOrNull(offsets[5]);
  object.whoReceived = reader.readString(offsets[6]);
  object.whoSent = reader.readString(offsets[7]);
  return object;
}

P _chatThreadDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _chatThreadGetId(ChatThread object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _chatThreadGetLinks(ChatThread object) {
  return [];
}

void _chatThreadAttach(IsarCollection<dynamic> col, Id id, ChatThread object) {}

extension ChatThreadQueryWhereSort
    on QueryBuilder<ChatThread, ChatThread, QWhere> {
  QueryBuilder<ChatThread, ChatThread, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChatThreadQueryWhere
    on QueryBuilder<ChatThread, ChatThread, QWhereClause> {
  QueryBuilder<ChatThread, ChatThread, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterWhereClause> whoSentEqualTo(
      String whoSent) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'whoSent',
        value: [whoSent],
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterWhereClause> whoSentNotEqualTo(
      String whoSent) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'whoSent',
              lower: [],
              upper: [whoSent],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'whoSent',
              lower: [whoSent],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'whoSent',
              lower: [whoSent],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'whoSent',
              lower: [],
              upper: [whoSent],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterWhereClause> whoReceivedEqualTo(
      String whoReceived) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'whoReceived',
        value: [whoReceived],
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterWhereClause> whoReceivedNotEqualTo(
      String whoReceived) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'whoReceived',
              lower: [],
              upper: [whoReceived],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'whoReceived',
              lower: [whoReceived],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'whoReceived',
              lower: [whoReceived],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'whoReceived',
              lower: [],
              upper: [whoReceived],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ChatThreadQueryFilter
    on QueryBuilder<ChatThread, ChatThread, QFilterCondition> {
  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMessage',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMessage',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMessageId',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMessageId',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMessageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      lastMessageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      messageTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'messageType',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      messageTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'messageType',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      messageTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      messageTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      messageTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      messageTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      messageTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'messageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      messageTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'messageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      messageTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'messageType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      messageTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'messageType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      messageTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageType',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      messageTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'messageType',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> timeStampEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeStamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      timeStampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeStamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> timeStampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeStamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> timeStampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeStamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      unreadCountJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unreadCountJson',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      unreadCountJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unreadCountJson',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      unreadCountJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unreadCountJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      unreadCountJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unreadCountJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      unreadCountJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unreadCountJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      unreadCountJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unreadCountJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      unreadCountJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unreadCountJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      unreadCountJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unreadCountJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      unreadCountJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unreadCountJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      unreadCountJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unreadCountJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      unreadCountJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unreadCountJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      unreadCountJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unreadCountJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      whoReceivedEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'whoReceived',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      whoReceivedGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'whoReceived',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      whoReceivedLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'whoReceived',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      whoReceivedBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'whoReceived',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      whoReceivedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'whoReceived',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      whoReceivedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'whoReceived',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      whoReceivedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'whoReceived',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      whoReceivedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'whoReceived',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      whoReceivedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'whoReceived',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      whoReceivedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'whoReceived',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> whoSentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'whoSent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      whoSentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'whoSent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> whoSentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'whoSent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> whoSentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'whoSent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> whoSentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'whoSent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> whoSentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'whoSent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> whoSentContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'whoSent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> whoSentMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'whoSent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition> whoSentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'whoSent',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterFilterCondition>
      whoSentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'whoSent',
        value: '',
      ));
    });
  }
}

extension ChatThreadQueryObject
    on QueryBuilder<ChatThread, ChatThread, QFilterCondition> {}

extension ChatThreadQueryLinks
    on QueryBuilder<ChatThread, ChatThread, QFilterCondition> {}

extension ChatThreadQuerySortBy
    on QueryBuilder<ChatThread, ChatThread, QSortBy> {
  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByLastMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessage', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByLastMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessage', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByLastMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByLastMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByMessageType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageType', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByMessageTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageType', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByTimeStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeStamp', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByTimeStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeStamp', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByUnreadCountJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCountJson', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy>
      sortByUnreadCountJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCountJson', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByWhoReceived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'whoReceived', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByWhoReceivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'whoReceived', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByWhoSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'whoSent', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> sortByWhoSentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'whoSent', Sort.desc);
    });
  }
}

extension ChatThreadQuerySortThenBy
    on QueryBuilder<ChatThread, ChatThread, QSortThenBy> {
  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByLastMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessage', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByLastMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessage', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByLastMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByLastMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByMessageType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageType', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByMessageTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageType', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByTimeStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeStamp', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByTimeStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeStamp', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByUnreadCountJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCountJson', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy>
      thenByUnreadCountJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCountJson', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByWhoReceived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'whoReceived', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByWhoReceivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'whoReceived', Sort.desc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByWhoSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'whoSent', Sort.asc);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QAfterSortBy> thenByWhoSentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'whoSent', Sort.desc);
    });
  }
}

extension ChatThreadQueryWhereDistinct
    on QueryBuilder<ChatThread, ChatThread, QDistinct> {
  QueryBuilder<ChatThread, ChatThread, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QDistinct> distinctByLastMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QDistinct> distinctByLastMessageId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessageId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QDistinct> distinctByMessageType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QDistinct> distinctByTimeStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeStamp');
    });
  }

  QueryBuilder<ChatThread, ChatThread, QDistinct> distinctByUnreadCountJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unreadCountJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QDistinct> distinctByWhoReceived(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'whoReceived', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatThread, ChatThread, QDistinct> distinctByWhoSent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'whoSent', caseSensitive: caseSensitive);
    });
  }
}

extension ChatThreadQueryProperty
    on QueryBuilder<ChatThread, ChatThread, QQueryProperty> {
  QueryBuilder<ChatThread, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ChatThread, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChatThread, String?, QQueryOperations> lastMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessage');
    });
  }

  QueryBuilder<ChatThread, String?, QQueryOperations> lastMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessageId');
    });
  }

  QueryBuilder<ChatThread, String?, QQueryOperations> messageTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageType');
    });
  }

  QueryBuilder<ChatThread, DateTime, QQueryOperations> timeStampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeStamp');
    });
  }

  QueryBuilder<ChatThread, String?, QQueryOperations>
      unreadCountJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unreadCountJson');
    });
  }

  QueryBuilder<ChatThread, String, QQueryOperations> whoReceivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'whoReceived');
    });
  }

  QueryBuilder<ChatThread, String, QQueryOperations> whoSentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'whoSent');
    });
  }
}
