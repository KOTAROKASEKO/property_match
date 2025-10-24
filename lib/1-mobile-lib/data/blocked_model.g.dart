// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBlockedUsersModelCollection on Isar {
  IsarCollection<BlockedUsersModel> get blockedUsersModels => this.collection();
}

const BlockedUsersModelSchema = CollectionSchema(
  name: r'BlockedUsersModel',
  id: 1195020560146205258,
  properties: {
    r'blockedUsers': PropertySchema(
      id: 0,
      name: r'blockedUsers',
      type: IsarType.stringList,
    )
  },
  estimateSize: _blockedUsersModelEstimateSize,
  serialize: _blockedUsersModelSerialize,
  deserialize: _blockedUsersModelDeserialize,
  deserializeProp: _blockedUsersModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _blockedUsersModelGetId,
  getLinks: _blockedUsersModelGetLinks,
  attach: _blockedUsersModelAttach,
  version: '3.1.0+1',
);

int _blockedUsersModelEstimateSize(
  BlockedUsersModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.blockedUsers.length * 3;
  {
    for (var i = 0; i < object.blockedUsers.length; i++) {
      final value = object.blockedUsers[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _blockedUsersModelSerialize(
  BlockedUsersModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.blockedUsers);
}

BlockedUsersModel _blockedUsersModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BlockedUsersModel();
  object.blockedUsers = reader.readStringList(offsets[0]) ?? [];
  object.id = id;
  return object;
}

P _blockedUsersModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _blockedUsersModelGetId(BlockedUsersModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _blockedUsersModelGetLinks(
    BlockedUsersModel object) {
  return [];
}

void _blockedUsersModelAttach(
    IsarCollection<dynamic> col, Id id, BlockedUsersModel object) {
  object.id = id;
}

extension BlockedUsersModelQueryWhereSort
    on QueryBuilder<BlockedUsersModel, BlockedUsersModel, QWhere> {
  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BlockedUsersModelQueryWhere
    on QueryBuilder<BlockedUsersModel, BlockedUsersModel, QWhereClause> {
  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterWhereClause>
      idBetween(
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

extension BlockedUsersModelQueryFilter
    on QueryBuilder<BlockedUsersModel, BlockedUsersModel, QFilterCondition> {
  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedUsers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockedUsers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockedUsers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockedUsers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'blockedUsers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'blockedUsers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'blockedUsers',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'blockedUsers',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedUsers',
        value: '',
      ));
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blockedUsers',
        value: '',
      ));
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedUsers',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedUsers',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedUsers',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedUsers',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedUsers',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      blockedUsersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedUsers',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
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

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterFilterCondition>
      idBetween(
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
}

extension BlockedUsersModelQueryObject
    on QueryBuilder<BlockedUsersModel, BlockedUsersModel, QFilterCondition> {}

extension BlockedUsersModelQueryLinks
    on QueryBuilder<BlockedUsersModel, BlockedUsersModel, QFilterCondition> {}

extension BlockedUsersModelQuerySortBy
    on QueryBuilder<BlockedUsersModel, BlockedUsersModel, QSortBy> {}

extension BlockedUsersModelQuerySortThenBy
    on QueryBuilder<BlockedUsersModel, BlockedUsersModel, QSortThenBy> {
  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension BlockedUsersModelQueryWhereDistinct
    on QueryBuilder<BlockedUsersModel, BlockedUsersModel, QDistinct> {
  QueryBuilder<BlockedUsersModel, BlockedUsersModel, QDistinct>
      distinctByBlockedUsers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockedUsers');
    });
  }
}

extension BlockedUsersModelQueryProperty
    on QueryBuilder<BlockedUsersModel, BlockedUsersModel, QQueryProperty> {
  QueryBuilder<BlockedUsersModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BlockedUsersModel, List<String>, QQueryOperations>
      blockedUsersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockedUsers');
    });
  }
}
