// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _chatRoomIdMeta = const VerificationMeta(
    'chatRoomId',
  );
  @override
  late final GeneratedColumn<String> chatRoomId = GeneratedColumn<String>(
    'chat_room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whoSentMeta = const VerificationMeta(
    'whoSent',
  );
  @override
  late final GeneratedColumn<String> whoSent = GeneratedColumn<String>(
    'who_sent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whoReceivedMeta = const VerificationMeta(
    'whoReceived',
  );
  @override
  late final GeneratedColumn<String> whoReceived = GeneratedColumn<String>(
    'who_received',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOutgoingMeta = const VerificationMeta(
    'isOutgoing',
  );
  @override
  late final GeneratedColumn<bool> isOutgoing = GeneratedColumn<bool>(
    'is_outgoing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_outgoing" IN (0, 1))',
    ),
  );
  static const VerificationMeta _messageTextMeta = const VerificationMeta(
    'messageText',
  );
  @override
  late final GeneratedColumn<String> messageText = GeneratedColumn<String>(
    'message_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageTypeMeta = const VerificationMeta(
    'messageType',
  );
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
    'message_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sending'),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyToMessageIdMeta = const VerificationMeta(
    'replyToMessageId',
  );
  @override
  late final GeneratedColumn<int> replyToMessageId = GeneratedColumn<int>(
    'reply_to_message_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repliedToMessageTextMeta =
      const VerificationMeta('repliedToMessageText');
  @override
  late final GeneratedColumn<String> repliedToMessageText =
      GeneratedColumn<String>(
        'replied_to_message_text',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _repliedToWhoSentMeta = const VerificationMeta(
    'repliedToWhoSent',
  );
  @override
  late final GeneratedColumn<String> repliedToWhoSent = GeneratedColumn<String>(
    'replied_to_who_sent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repliedToMessageIdMeta =
      const VerificationMeta('repliedToMessageId');
  @override
  late final GeneratedColumn<String> repliedToMessageId =
      GeneratedColumn<String>(
        'replied_to_message_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    chatRoomId,
    whoSent,
    whoReceived,
    isOutgoing,
    messageText,
    messageType,
    operation,
    status,
    isRead,
    timestamp,
    editedAt,
    localPath,
    remoteUrl,
    thumbnailPath,
    replyToMessageId,
    repliedToMessageText,
    repliedToWhoSent,
    repliedToMessageId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('chat_room_id')) {
      context.handle(
        _chatRoomIdMeta,
        chatRoomId.isAcceptableOrUnknown(
          data['chat_room_id']!,
          _chatRoomIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chatRoomIdMeta);
    }
    if (data.containsKey('who_sent')) {
      context.handle(
        _whoSentMeta,
        whoSent.isAcceptableOrUnknown(data['who_sent']!, _whoSentMeta),
      );
    } else if (isInserting) {
      context.missing(_whoSentMeta);
    }
    if (data.containsKey('who_received')) {
      context.handle(
        _whoReceivedMeta,
        whoReceived.isAcceptableOrUnknown(
          data['who_received']!,
          _whoReceivedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_whoReceivedMeta);
    }
    if (data.containsKey('is_outgoing')) {
      context.handle(
        _isOutgoingMeta,
        isOutgoing.isAcceptableOrUnknown(data['is_outgoing']!, _isOutgoingMeta),
      );
    } else if (isInserting) {
      context.missing(_isOutgoingMeta);
    }
    if (data.containsKey('message_text')) {
      context.handle(
        _messageTextMeta,
        messageText.isAcceptableOrUnknown(
          data['message_text']!,
          _messageTextMeta,
        ),
      );
    }
    if (data.containsKey('message_type')) {
      context.handle(
        _messageTypeMeta,
        messageType.isAcceptableOrUnknown(
          data['message_type']!,
          _messageTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageTypeMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('reply_to_message_id')) {
      context.handle(
        _replyToMessageIdMeta,
        replyToMessageId.isAcceptableOrUnknown(
          data['reply_to_message_id']!,
          _replyToMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('replied_to_message_text')) {
      context.handle(
        _repliedToMessageTextMeta,
        repliedToMessageText.isAcceptableOrUnknown(
          data['replied_to_message_text']!,
          _repliedToMessageTextMeta,
        ),
      );
    }
    if (data.containsKey('replied_to_who_sent')) {
      context.handle(
        _repliedToWhoSentMeta,
        repliedToWhoSent.isAcceptableOrUnknown(
          data['replied_to_who_sent']!,
          _repliedToWhoSentMeta,
        ),
      );
    }
    if (data.containsKey('replied_to_message_id')) {
      context.handle(
        _repliedToMessageIdMeta,
        repliedToMessageId.isAcceptableOrUnknown(
          data['replied_to_message_id']!,
          _repliedToMessageIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      chatRoomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_room_id'],
      )!,
      whoSent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}who_sent'],
      )!,
      whoReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}who_received'],
      )!,
      isOutgoing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_outgoing'],
      )!,
      messageText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_text'],
      ),
      messageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_type'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edited_at'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      replyToMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reply_to_message_id'],
      ),
      repliedToMessageText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replied_to_message_text'],
      ),
      repliedToWhoSent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replied_to_who_sent'],
      ),
      repliedToMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replied_to_message_id'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class MessageRow extends DataClass implements Insertable<MessageRow> {
  final int id;
  final String messageId;
  final String chatRoomId;
  final String whoSent;
  final String whoReceived;
  final bool isOutgoing;
  final String? messageText;
  final String messageType;
  final String operation;
  final String status;
  final bool isRead;
  final DateTime timestamp;
  final DateTime? editedAt;
  final String? localPath;
  final String? remoteUrl;
  final String? thumbnailPath;
  final int? replyToMessageId;
  final String? repliedToMessageText;
  final String? repliedToWhoSent;
  final String? repliedToMessageId;
  const MessageRow({
    required this.id,
    required this.messageId,
    required this.chatRoomId,
    required this.whoSent,
    required this.whoReceived,
    required this.isOutgoing,
    this.messageText,
    required this.messageType,
    required this.operation,
    required this.status,
    required this.isRead,
    required this.timestamp,
    this.editedAt,
    this.localPath,
    this.remoteUrl,
    this.thumbnailPath,
    this.replyToMessageId,
    this.repliedToMessageText,
    this.repliedToWhoSent,
    this.repliedToMessageId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['chat_room_id'] = Variable<String>(chatRoomId);
    map['who_sent'] = Variable<String>(whoSent);
    map['who_received'] = Variable<String>(whoReceived);
    map['is_outgoing'] = Variable<bool>(isOutgoing);
    if (!nullToAbsent || messageText != null) {
      map['message_text'] = Variable<String>(messageText);
    }
    map['message_type'] = Variable<String>(messageType);
    map['operation'] = Variable<String>(operation);
    map['status'] = Variable<String>(status);
    map['is_read'] = Variable<bool>(isRead);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<DateTime>(editedAt);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || replyToMessageId != null) {
      map['reply_to_message_id'] = Variable<int>(replyToMessageId);
    }
    if (!nullToAbsent || repliedToMessageText != null) {
      map['replied_to_message_text'] = Variable<String>(repliedToMessageText);
    }
    if (!nullToAbsent || repliedToWhoSent != null) {
      map['replied_to_who_sent'] = Variable<String>(repliedToWhoSent);
    }
    if (!nullToAbsent || repliedToMessageId != null) {
      map['replied_to_message_id'] = Variable<String>(repliedToMessageId);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      messageId: Value(messageId),
      chatRoomId: Value(chatRoomId),
      whoSent: Value(whoSent),
      whoReceived: Value(whoReceived),
      isOutgoing: Value(isOutgoing),
      messageText: messageText == null && nullToAbsent
          ? const Value.absent()
          : Value(messageText),
      messageType: Value(messageType),
      operation: Value(operation),
      status: Value(status),
      isRead: Value(isRead),
      timestamp: Value(timestamp),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      replyToMessageId: replyToMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToMessageId),
      repliedToMessageText: repliedToMessageText == null && nullToAbsent
          ? const Value.absent()
          : Value(repliedToMessageText),
      repliedToWhoSent: repliedToWhoSent == null && nullToAbsent
          ? const Value.absent()
          : Value(repliedToWhoSent),
      repliedToMessageId: repliedToMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(repliedToMessageId),
    );
  }

  factory MessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRow(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      chatRoomId: serializer.fromJson<String>(json['chatRoomId']),
      whoSent: serializer.fromJson<String>(json['whoSent']),
      whoReceived: serializer.fromJson<String>(json['whoReceived']),
      isOutgoing: serializer.fromJson<bool>(json['isOutgoing']),
      messageText: serializer.fromJson<String?>(json['messageText']),
      messageType: serializer.fromJson<String>(json['messageType']),
      operation: serializer.fromJson<String>(json['operation']),
      status: serializer.fromJson<String>(json['status']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      editedAt: serializer.fromJson<DateTime?>(json['editedAt']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      replyToMessageId: serializer.fromJson<int?>(json['replyToMessageId']),
      repliedToMessageText: serializer.fromJson<String?>(
        json['repliedToMessageText'],
      ),
      repliedToWhoSent: serializer.fromJson<String?>(json['repliedToWhoSent']),
      repliedToMessageId: serializer.fromJson<String?>(
        json['repliedToMessageId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<String>(messageId),
      'chatRoomId': serializer.toJson<String>(chatRoomId),
      'whoSent': serializer.toJson<String>(whoSent),
      'whoReceived': serializer.toJson<String>(whoReceived),
      'isOutgoing': serializer.toJson<bool>(isOutgoing),
      'messageText': serializer.toJson<String?>(messageText),
      'messageType': serializer.toJson<String>(messageType),
      'operation': serializer.toJson<String>(operation),
      'status': serializer.toJson<String>(status),
      'isRead': serializer.toJson<bool>(isRead),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'editedAt': serializer.toJson<DateTime?>(editedAt),
      'localPath': serializer.toJson<String?>(localPath),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'replyToMessageId': serializer.toJson<int?>(replyToMessageId),
      'repliedToMessageText': serializer.toJson<String?>(repliedToMessageText),
      'repliedToWhoSent': serializer.toJson<String?>(repliedToWhoSent),
      'repliedToMessageId': serializer.toJson<String?>(repliedToMessageId),
    };
  }

  MessageRow copyWith({
    int? id,
    String? messageId,
    String? chatRoomId,
    String? whoSent,
    String? whoReceived,
    bool? isOutgoing,
    Value<String?> messageText = const Value.absent(),
    String? messageType,
    String? operation,
    String? status,
    bool? isRead,
    DateTime? timestamp,
    Value<DateTime?> editedAt = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    Value<String?> remoteUrl = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
    Value<int?> replyToMessageId = const Value.absent(),
    Value<String?> repliedToMessageText = const Value.absent(),
    Value<String?> repliedToWhoSent = const Value.absent(),
    Value<String?> repliedToMessageId = const Value.absent(),
  }) => MessageRow(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    chatRoomId: chatRoomId ?? this.chatRoomId,
    whoSent: whoSent ?? this.whoSent,
    whoReceived: whoReceived ?? this.whoReceived,
    isOutgoing: isOutgoing ?? this.isOutgoing,
    messageText: messageText.present ? messageText.value : this.messageText,
    messageType: messageType ?? this.messageType,
    operation: operation ?? this.operation,
    status: status ?? this.status,
    isRead: isRead ?? this.isRead,
    timestamp: timestamp ?? this.timestamp,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
    localPath: localPath.present ? localPath.value : this.localPath,
    remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    replyToMessageId: replyToMessageId.present
        ? replyToMessageId.value
        : this.replyToMessageId,
    repliedToMessageText: repliedToMessageText.present
        ? repliedToMessageText.value
        : this.repliedToMessageText,
    repliedToWhoSent: repliedToWhoSent.present
        ? repliedToWhoSent.value
        : this.repliedToWhoSent,
    repliedToMessageId: repliedToMessageId.present
        ? repliedToMessageId.value
        : this.repliedToMessageId,
  );
  MessageRow copyWithCompanion(MessagesCompanion data) {
    return MessageRow(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      chatRoomId: data.chatRoomId.present
          ? data.chatRoomId.value
          : this.chatRoomId,
      whoSent: data.whoSent.present ? data.whoSent.value : this.whoSent,
      whoReceived: data.whoReceived.present
          ? data.whoReceived.value
          : this.whoReceived,
      isOutgoing: data.isOutgoing.present
          ? data.isOutgoing.value
          : this.isOutgoing,
      messageText: data.messageText.present
          ? data.messageText.value
          : this.messageText,
      messageType: data.messageType.present
          ? data.messageType.value
          : this.messageType,
      operation: data.operation.present ? data.operation.value : this.operation,
      status: data.status.present ? data.status.value : this.status,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      replyToMessageId: data.replyToMessageId.present
          ? data.replyToMessageId.value
          : this.replyToMessageId,
      repliedToMessageText: data.repliedToMessageText.present
          ? data.repliedToMessageText.value
          : this.repliedToMessageText,
      repliedToWhoSent: data.repliedToWhoSent.present
          ? data.repliedToWhoSent.value
          : this.repliedToWhoSent,
      repliedToMessageId: data.repliedToMessageId.present
          ? data.repliedToMessageId.value
          : this.repliedToMessageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRow(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('whoSent: $whoSent, ')
          ..write('whoReceived: $whoReceived, ')
          ..write('isOutgoing: $isOutgoing, ')
          ..write('messageText: $messageText, ')
          ..write('messageType: $messageType, ')
          ..write('operation: $operation, ')
          ..write('status: $status, ')
          ..write('isRead: $isRead, ')
          ..write('timestamp: $timestamp, ')
          ..write('editedAt: $editedAt, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('replyToMessageId: $replyToMessageId, ')
          ..write('repliedToMessageText: $repliedToMessageText, ')
          ..write('repliedToWhoSent: $repliedToWhoSent, ')
          ..write('repliedToMessageId: $repliedToMessageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageId,
    chatRoomId,
    whoSent,
    whoReceived,
    isOutgoing,
    messageText,
    messageType,
    operation,
    status,
    isRead,
    timestamp,
    editedAt,
    localPath,
    remoteUrl,
    thumbnailPath,
    replyToMessageId,
    repliedToMessageText,
    repliedToWhoSent,
    repliedToMessageId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRow &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.chatRoomId == this.chatRoomId &&
          other.whoSent == this.whoSent &&
          other.whoReceived == this.whoReceived &&
          other.isOutgoing == this.isOutgoing &&
          other.messageText == this.messageText &&
          other.messageType == this.messageType &&
          other.operation == this.operation &&
          other.status == this.status &&
          other.isRead == this.isRead &&
          other.timestamp == this.timestamp &&
          other.editedAt == this.editedAt &&
          other.localPath == this.localPath &&
          other.remoteUrl == this.remoteUrl &&
          other.thumbnailPath == this.thumbnailPath &&
          other.replyToMessageId == this.replyToMessageId &&
          other.repliedToMessageText == this.repliedToMessageText &&
          other.repliedToWhoSent == this.repliedToWhoSent &&
          other.repliedToMessageId == this.repliedToMessageId);
}

class MessagesCompanion extends UpdateCompanion<MessageRow> {
  final Value<int> id;
  final Value<String> messageId;
  final Value<String> chatRoomId;
  final Value<String> whoSent;
  final Value<String> whoReceived;
  final Value<bool> isOutgoing;
  final Value<String?> messageText;
  final Value<String> messageType;
  final Value<String> operation;
  final Value<String> status;
  final Value<bool> isRead;
  final Value<DateTime> timestamp;
  final Value<DateTime?> editedAt;
  final Value<String?> localPath;
  final Value<String?> remoteUrl;
  final Value<String?> thumbnailPath;
  final Value<int?> replyToMessageId;
  final Value<String?> repliedToMessageText;
  final Value<String?> repliedToWhoSent;
  final Value<String?> repliedToMessageId;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.chatRoomId = const Value.absent(),
    this.whoSent = const Value.absent(),
    this.whoReceived = const Value.absent(),
    this.isOutgoing = const Value.absent(),
    this.messageText = const Value.absent(),
    this.messageType = const Value.absent(),
    this.operation = const Value.absent(),
    this.status = const Value.absent(),
    this.isRead = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.localPath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.replyToMessageId = const Value.absent(),
    this.repliedToMessageText = const Value.absent(),
    this.repliedToWhoSent = const Value.absent(),
    this.repliedToMessageId = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required String messageId,
    required String chatRoomId,
    required String whoSent,
    required String whoReceived,
    required bool isOutgoing,
    this.messageText = const Value.absent(),
    required String messageType,
    this.operation = const Value.absent(),
    this.status = const Value.absent(),
    this.isRead = const Value.absent(),
    required DateTime timestamp,
    this.editedAt = const Value.absent(),
    this.localPath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.replyToMessageId = const Value.absent(),
    this.repliedToMessageText = const Value.absent(),
    this.repliedToWhoSent = const Value.absent(),
    this.repliedToMessageId = const Value.absent(),
  }) : messageId = Value(messageId),
       chatRoomId = Value(chatRoomId),
       whoSent = Value(whoSent),
       whoReceived = Value(whoReceived),
       isOutgoing = Value(isOutgoing),
       messageType = Value(messageType),
       timestamp = Value(timestamp);
  static Insertable<MessageRow> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<String>? chatRoomId,
    Expression<String>? whoSent,
    Expression<String>? whoReceived,
    Expression<bool>? isOutgoing,
    Expression<String>? messageText,
    Expression<String>? messageType,
    Expression<String>? operation,
    Expression<String>? status,
    Expression<bool>? isRead,
    Expression<DateTime>? timestamp,
    Expression<DateTime>? editedAt,
    Expression<String>? localPath,
    Expression<String>? remoteUrl,
    Expression<String>? thumbnailPath,
    Expression<int>? replyToMessageId,
    Expression<String>? repliedToMessageText,
    Expression<String>? repliedToWhoSent,
    Expression<String>? repliedToMessageId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (chatRoomId != null) 'chat_room_id': chatRoomId,
      if (whoSent != null) 'who_sent': whoSent,
      if (whoReceived != null) 'who_received': whoReceived,
      if (isOutgoing != null) 'is_outgoing': isOutgoing,
      if (messageText != null) 'message_text': messageText,
      if (messageType != null) 'message_type': messageType,
      if (operation != null) 'operation': operation,
      if (status != null) 'status': status,
      if (isRead != null) 'is_read': isRead,
      if (timestamp != null) 'timestamp': timestamp,
      if (editedAt != null) 'edited_at': editedAt,
      if (localPath != null) 'local_path': localPath,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
      if (repliedToMessageText != null)
        'replied_to_message_text': repliedToMessageText,
      if (repliedToWhoSent != null) 'replied_to_who_sent': repliedToWhoSent,
      if (repliedToMessageId != null)
        'replied_to_message_id': repliedToMessageId,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? messageId,
    Value<String>? chatRoomId,
    Value<String>? whoSent,
    Value<String>? whoReceived,
    Value<bool>? isOutgoing,
    Value<String?>? messageText,
    Value<String>? messageType,
    Value<String>? operation,
    Value<String>? status,
    Value<bool>? isRead,
    Value<DateTime>? timestamp,
    Value<DateTime?>? editedAt,
    Value<String?>? localPath,
    Value<String?>? remoteUrl,
    Value<String?>? thumbnailPath,
    Value<int?>? replyToMessageId,
    Value<String?>? repliedToMessageText,
    Value<String?>? repliedToWhoSent,
    Value<String?>? repliedToMessageId,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      whoSent: whoSent ?? this.whoSent,
      whoReceived: whoReceived ?? this.whoReceived,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      messageText: messageText ?? this.messageText,
      messageType: messageType ?? this.messageType,
      operation: operation ?? this.operation,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      repliedToMessageText: repliedToMessageText ?? this.repliedToMessageText,
      repliedToWhoSent: repliedToWhoSent ?? this.repliedToWhoSent,
      repliedToMessageId: repliedToMessageId ?? this.repliedToMessageId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (chatRoomId.present) {
      map['chat_room_id'] = Variable<String>(chatRoomId.value);
    }
    if (whoSent.present) {
      map['who_sent'] = Variable<String>(whoSent.value);
    }
    if (whoReceived.present) {
      map['who_received'] = Variable<String>(whoReceived.value);
    }
    if (isOutgoing.present) {
      map['is_outgoing'] = Variable<bool>(isOutgoing.value);
    }
    if (messageText.present) {
      map['message_text'] = Variable<String>(messageText.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (replyToMessageId.present) {
      map['reply_to_message_id'] = Variable<int>(replyToMessageId.value);
    }
    if (repliedToMessageText.present) {
      map['replied_to_message_text'] = Variable<String>(
        repliedToMessageText.value,
      );
    }
    if (repliedToWhoSent.present) {
      map['replied_to_who_sent'] = Variable<String>(repliedToWhoSent.value);
    }
    if (repliedToMessageId.present) {
      map['replied_to_message_id'] = Variable<String>(repliedToMessageId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('whoSent: $whoSent, ')
          ..write('whoReceived: $whoReceived, ')
          ..write('isOutgoing: $isOutgoing, ')
          ..write('messageText: $messageText, ')
          ..write('messageType: $messageType, ')
          ..write('operation: $operation, ')
          ..write('status: $status, ')
          ..write('isRead: $isRead, ')
          ..write('timestamp: $timestamp, ')
          ..write('editedAt: $editedAt, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('replyToMessageId: $replyToMessageId, ')
          ..write('repliedToMessageText: $repliedToMessageText, ')
          ..write('repliedToWhoSent: $repliedToWhoSent, ')
          ..write('repliedToMessageId: $repliedToMessageId')
          ..write(')'))
        .toString();
  }
}

class $ChatThreadsTable extends ChatThreads
    with TableInfo<$ChatThreadsTable, ChatThreadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatThreadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whoSentMeta = const VerificationMeta(
    'whoSent',
  );
  @override
  late final GeneratedColumn<String> whoSent = GeneratedColumn<String>(
    'who_sent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whoReceivedMeta = const VerificationMeta(
    'whoReceived',
  );
  @override
  late final GeneratedColumn<String> whoReceived = GeneratedColumn<String>(
    'who_received',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hisNameMeta = const VerificationMeta(
    'hisName',
  );
  @override
  late final GeneratedColumn<String> hisName = GeneratedColumn<String>(
    'his_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hisPhotoUrlMeta = const VerificationMeta(
    'hisPhotoUrl',
  );
  @override
  late final GeneratedColumn<String> hisPhotoUrl = GeneratedColumn<String>(
    'his_photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageMeta = const VerificationMeta(
    'lastMessage',
  );
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
    'last_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeStampMeta = const VerificationMeta(
    'timeStamp',
  );
  @override
  late final GeneratedColumn<DateTime> timeStamp = GeneratedColumn<DateTime>(
    'time_stamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageTypeMeta = const VerificationMeta(
    'messageType',
  );
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
    'message_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageIdMeta = const VerificationMeta(
    'lastMessageId',
  );
  @override
  late final GeneratedColumn<String> lastMessageId = GeneratedColumn<String>(
    'last_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unreadCountJsonMeta = const VerificationMeta(
    'unreadCountJson',
  );
  @override
  late final GeneratedColumn<String> unreadCountJson = GeneratedColumn<String>(
    'unread_count_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _generalNoteMeta = const VerificationMeta(
    'generalNote',
  );
  @override
  late final GeneratedColumn<String> generalNote = GeneratedColumn<String>(
    'general_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  generalImageUrls = GeneratedColumn<String>(
    'general_image_urls',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($ChatThreadsTable.$convertergeneralImageUrls);
  @override
  late final GeneratedColumnWithTypeConverter<List<DateTime>, String>
  viewingTimes = GeneratedColumn<String>(
    'viewing_times',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<DateTime>>($ChatThreadsTable.$converterviewingTimes);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  viewingNotes = GeneratedColumn<String>(
    'viewing_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($ChatThreadsTable.$converterviewingNotes);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  viewingImageUrls = GeneratedColumn<String>(
    'viewing_image_urls',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($ChatThreadsTable.$converterviewingImageUrls);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    whoSent,
    whoReceived,
    hisName,
    hisPhotoUrl,
    lastMessage,
    timeStamp,
    messageType,
    lastMessageId,
    unreadCountJson,
    generalNote,
    generalImageUrls,
    viewingTimes,
    viewingNotes,
    viewingImageUrls,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_threads';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatThreadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('who_sent')) {
      context.handle(
        _whoSentMeta,
        whoSent.isAcceptableOrUnknown(data['who_sent']!, _whoSentMeta),
      );
    } else if (isInserting) {
      context.missing(_whoSentMeta);
    }
    if (data.containsKey('who_received')) {
      context.handle(
        _whoReceivedMeta,
        whoReceived.isAcceptableOrUnknown(
          data['who_received']!,
          _whoReceivedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_whoReceivedMeta);
    }
    if (data.containsKey('his_name')) {
      context.handle(
        _hisNameMeta,
        hisName.isAcceptableOrUnknown(data['his_name']!, _hisNameMeta),
      );
    }
    if (data.containsKey('his_photo_url')) {
      context.handle(
        _hisPhotoUrlMeta,
        hisPhotoUrl.isAcceptableOrUnknown(
          data['his_photo_url']!,
          _hisPhotoUrlMeta,
        ),
      );
    }
    if (data.containsKey('last_message')) {
      context.handle(
        _lastMessageMeta,
        lastMessage.isAcceptableOrUnknown(
          data['last_message']!,
          _lastMessageMeta,
        ),
      );
    }
    if (data.containsKey('time_stamp')) {
      context.handle(
        _timeStampMeta,
        timeStamp.isAcceptableOrUnknown(data['time_stamp']!, _timeStampMeta),
      );
    } else if (isInserting) {
      context.missing(_timeStampMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
        _messageTypeMeta,
        messageType.isAcceptableOrUnknown(
          data['message_type']!,
          _messageTypeMeta,
        ),
      );
    }
    if (data.containsKey('last_message_id')) {
      context.handle(
        _lastMessageIdMeta,
        lastMessageId.isAcceptableOrUnknown(
          data['last_message_id']!,
          _lastMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('unread_count_json')) {
      context.handle(
        _unreadCountJsonMeta,
        unreadCountJson.isAcceptableOrUnknown(
          data['unread_count_json']!,
          _unreadCountJsonMeta,
        ),
      );
    }
    if (data.containsKey('general_note')) {
      context.handle(
        _generalNoteMeta,
        generalNote.isAcceptableOrUnknown(
          data['general_note']!,
          _generalNoteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatThreadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatThreadRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      whoSent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}who_sent'],
      )!,
      whoReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}who_received'],
      )!,
      hisName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}his_name'],
      ),
      hisPhotoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}his_photo_url'],
      ),
      lastMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message'],
      ),
      timeStamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time_stamp'],
      )!,
      messageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_type'],
      ),
      lastMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_id'],
      ),
      unreadCountJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unread_count_json'],
      ),
      generalNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}general_note'],
      ),
      generalImageUrls: $ChatThreadsTable.$convertergeneralImageUrls.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}general_image_urls'],
        )!,
      ),
      viewingTimes: $ChatThreadsTable.$converterviewingTimes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}viewing_times'],
        )!,
      ),
      viewingNotes: $ChatThreadsTable.$converterviewingNotes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}viewing_notes'],
        )!,
      ),
      viewingImageUrls: $ChatThreadsTable.$converterviewingImageUrls.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}viewing_image_urls'],
        )!,
      ),
    );
  }

  @override
  $ChatThreadsTable createAlias(String alias) {
    return $ChatThreadsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertergeneralImageUrls =
      const JsonStringListConverter();
  static TypeConverter<List<DateTime>, String> $converterviewingTimes =
      const JsonDateTimeListConverter();
  static TypeConverter<List<String>, String> $converterviewingNotes =
      const JsonStringListConverter();
  static TypeConverter<List<String>, String> $converterviewingImageUrls =
      const JsonStringListConverter();
}

class ChatThreadRow extends DataClass implements Insertable<ChatThreadRow> {
  final String id;
  final String whoSent;
  final String whoReceived;
  final String? hisName;
  final String? hisPhotoUrl;
  final String? lastMessage;
  final DateTime timeStamp;
  final String? messageType;
  final String? lastMessageId;
  final String? unreadCountJson;
  final String? generalNote;
  final List<String> generalImageUrls;
  final List<DateTime> viewingTimes;
  final List<String> viewingNotes;
  final List<String> viewingImageUrls;
  const ChatThreadRow({
    required this.id,
    required this.whoSent,
    required this.whoReceived,
    this.hisName,
    this.hisPhotoUrl,
    this.lastMessage,
    required this.timeStamp,
    this.messageType,
    this.lastMessageId,
    this.unreadCountJson,
    this.generalNote,
    required this.generalImageUrls,
    required this.viewingTimes,
    required this.viewingNotes,
    required this.viewingImageUrls,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['who_sent'] = Variable<String>(whoSent);
    map['who_received'] = Variable<String>(whoReceived);
    if (!nullToAbsent || hisName != null) {
      map['his_name'] = Variable<String>(hisName);
    }
    if (!nullToAbsent || hisPhotoUrl != null) {
      map['his_photo_url'] = Variable<String>(hisPhotoUrl);
    }
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
    }
    map['time_stamp'] = Variable<DateTime>(timeStamp);
    if (!nullToAbsent || messageType != null) {
      map['message_type'] = Variable<String>(messageType);
    }
    if (!nullToAbsent || lastMessageId != null) {
      map['last_message_id'] = Variable<String>(lastMessageId);
    }
    if (!nullToAbsent || unreadCountJson != null) {
      map['unread_count_json'] = Variable<String>(unreadCountJson);
    }
    if (!nullToAbsent || generalNote != null) {
      map['general_note'] = Variable<String>(generalNote);
    }
    {
      map['general_image_urls'] = Variable<String>(
        $ChatThreadsTable.$convertergeneralImageUrls.toSql(generalImageUrls),
      );
    }
    {
      map['viewing_times'] = Variable<String>(
        $ChatThreadsTable.$converterviewingTimes.toSql(viewingTimes),
      );
    }
    {
      map['viewing_notes'] = Variable<String>(
        $ChatThreadsTable.$converterviewingNotes.toSql(viewingNotes),
      );
    }
    {
      map['viewing_image_urls'] = Variable<String>(
        $ChatThreadsTable.$converterviewingImageUrls.toSql(viewingImageUrls),
      );
    }
    return map;
  }

  ChatThreadsCompanion toCompanion(bool nullToAbsent) {
    return ChatThreadsCompanion(
      id: Value(id),
      whoSent: Value(whoSent),
      whoReceived: Value(whoReceived),
      hisName: hisName == null && nullToAbsent
          ? const Value.absent()
          : Value(hisName),
      hisPhotoUrl: hisPhotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(hisPhotoUrl),
      lastMessage: lastMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessage),
      timeStamp: Value(timeStamp),
      messageType: messageType == null && nullToAbsent
          ? const Value.absent()
          : Value(messageType),
      lastMessageId: lastMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageId),
      unreadCountJson: unreadCountJson == null && nullToAbsent
          ? const Value.absent()
          : Value(unreadCountJson),
      generalNote: generalNote == null && nullToAbsent
          ? const Value.absent()
          : Value(generalNote),
      generalImageUrls: Value(generalImageUrls),
      viewingTimes: Value(viewingTimes),
      viewingNotes: Value(viewingNotes),
      viewingImageUrls: Value(viewingImageUrls),
    );
  }

  factory ChatThreadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatThreadRow(
      id: serializer.fromJson<String>(json['id']),
      whoSent: serializer.fromJson<String>(json['whoSent']),
      whoReceived: serializer.fromJson<String>(json['whoReceived']),
      hisName: serializer.fromJson<String?>(json['hisName']),
      hisPhotoUrl: serializer.fromJson<String?>(json['hisPhotoUrl']),
      lastMessage: serializer.fromJson<String?>(json['lastMessage']),
      timeStamp: serializer.fromJson<DateTime>(json['timeStamp']),
      messageType: serializer.fromJson<String?>(json['messageType']),
      lastMessageId: serializer.fromJson<String?>(json['lastMessageId']),
      unreadCountJson: serializer.fromJson<String?>(json['unreadCountJson']),
      generalNote: serializer.fromJson<String?>(json['generalNote']),
      generalImageUrls: serializer.fromJson<List<String>>(
        json['generalImageUrls'],
      ),
      viewingTimes: serializer.fromJson<List<DateTime>>(json['viewingTimes']),
      viewingNotes: serializer.fromJson<List<String>>(json['viewingNotes']),
      viewingImageUrls: serializer.fromJson<List<String>>(
        json['viewingImageUrls'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'whoSent': serializer.toJson<String>(whoSent),
      'whoReceived': serializer.toJson<String>(whoReceived),
      'hisName': serializer.toJson<String?>(hisName),
      'hisPhotoUrl': serializer.toJson<String?>(hisPhotoUrl),
      'lastMessage': serializer.toJson<String?>(lastMessage),
      'timeStamp': serializer.toJson<DateTime>(timeStamp),
      'messageType': serializer.toJson<String?>(messageType),
      'lastMessageId': serializer.toJson<String?>(lastMessageId),
      'unreadCountJson': serializer.toJson<String?>(unreadCountJson),
      'generalNote': serializer.toJson<String?>(generalNote),
      'generalImageUrls': serializer.toJson<List<String>>(generalImageUrls),
      'viewingTimes': serializer.toJson<List<DateTime>>(viewingTimes),
      'viewingNotes': serializer.toJson<List<String>>(viewingNotes),
      'viewingImageUrls': serializer.toJson<List<String>>(viewingImageUrls),
    };
  }

  ChatThreadRow copyWith({
    String? id,
    String? whoSent,
    String? whoReceived,
    Value<String?> hisName = const Value.absent(),
    Value<String?> hisPhotoUrl = const Value.absent(),
    Value<String?> lastMessage = const Value.absent(),
    DateTime? timeStamp,
    Value<String?> messageType = const Value.absent(),
    Value<String?> lastMessageId = const Value.absent(),
    Value<String?> unreadCountJson = const Value.absent(),
    Value<String?> generalNote = const Value.absent(),
    List<String>? generalImageUrls,
    List<DateTime>? viewingTimes,
    List<String>? viewingNotes,
    List<String>? viewingImageUrls,
  }) => ChatThreadRow(
    id: id ?? this.id,
    whoSent: whoSent ?? this.whoSent,
    whoReceived: whoReceived ?? this.whoReceived,
    hisName: hisName.present ? hisName.value : this.hisName,
    hisPhotoUrl: hisPhotoUrl.present ? hisPhotoUrl.value : this.hisPhotoUrl,
    lastMessage: lastMessage.present ? lastMessage.value : this.lastMessage,
    timeStamp: timeStamp ?? this.timeStamp,
    messageType: messageType.present ? messageType.value : this.messageType,
    lastMessageId: lastMessageId.present
        ? lastMessageId.value
        : this.lastMessageId,
    unreadCountJson: unreadCountJson.present
        ? unreadCountJson.value
        : this.unreadCountJson,
    generalNote: generalNote.present ? generalNote.value : this.generalNote,
    generalImageUrls: generalImageUrls ?? this.generalImageUrls,
    viewingTimes: viewingTimes ?? this.viewingTimes,
    viewingNotes: viewingNotes ?? this.viewingNotes,
    viewingImageUrls: viewingImageUrls ?? this.viewingImageUrls,
  );
  ChatThreadRow copyWithCompanion(ChatThreadsCompanion data) {
    return ChatThreadRow(
      id: data.id.present ? data.id.value : this.id,
      whoSent: data.whoSent.present ? data.whoSent.value : this.whoSent,
      whoReceived: data.whoReceived.present
          ? data.whoReceived.value
          : this.whoReceived,
      hisName: data.hisName.present ? data.hisName.value : this.hisName,
      hisPhotoUrl: data.hisPhotoUrl.present
          ? data.hisPhotoUrl.value
          : this.hisPhotoUrl,
      lastMessage: data.lastMessage.present
          ? data.lastMessage.value
          : this.lastMessage,
      timeStamp: data.timeStamp.present ? data.timeStamp.value : this.timeStamp,
      messageType: data.messageType.present
          ? data.messageType.value
          : this.messageType,
      lastMessageId: data.lastMessageId.present
          ? data.lastMessageId.value
          : this.lastMessageId,
      unreadCountJson: data.unreadCountJson.present
          ? data.unreadCountJson.value
          : this.unreadCountJson,
      generalNote: data.generalNote.present
          ? data.generalNote.value
          : this.generalNote,
      generalImageUrls: data.generalImageUrls.present
          ? data.generalImageUrls.value
          : this.generalImageUrls,
      viewingTimes: data.viewingTimes.present
          ? data.viewingTimes.value
          : this.viewingTimes,
      viewingNotes: data.viewingNotes.present
          ? data.viewingNotes.value
          : this.viewingNotes,
      viewingImageUrls: data.viewingImageUrls.present
          ? data.viewingImageUrls.value
          : this.viewingImageUrls,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatThreadRow(')
          ..write('id: $id, ')
          ..write('whoSent: $whoSent, ')
          ..write('whoReceived: $whoReceived, ')
          ..write('hisName: $hisName, ')
          ..write('hisPhotoUrl: $hisPhotoUrl, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('timeStamp: $timeStamp, ')
          ..write('messageType: $messageType, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('unreadCountJson: $unreadCountJson, ')
          ..write('generalNote: $generalNote, ')
          ..write('generalImageUrls: $generalImageUrls, ')
          ..write('viewingTimes: $viewingTimes, ')
          ..write('viewingNotes: $viewingNotes, ')
          ..write('viewingImageUrls: $viewingImageUrls')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    whoSent,
    whoReceived,
    hisName,
    hisPhotoUrl,
    lastMessage,
    timeStamp,
    messageType,
    lastMessageId,
    unreadCountJson,
    generalNote,
    generalImageUrls,
    viewingTimes,
    viewingNotes,
    viewingImageUrls,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatThreadRow &&
          other.id == this.id &&
          other.whoSent == this.whoSent &&
          other.whoReceived == this.whoReceived &&
          other.hisName == this.hisName &&
          other.hisPhotoUrl == this.hisPhotoUrl &&
          other.lastMessage == this.lastMessage &&
          other.timeStamp == this.timeStamp &&
          other.messageType == this.messageType &&
          other.lastMessageId == this.lastMessageId &&
          other.unreadCountJson == this.unreadCountJson &&
          other.generalNote == this.generalNote &&
          other.generalImageUrls == this.generalImageUrls &&
          other.viewingTimes == this.viewingTimes &&
          other.viewingNotes == this.viewingNotes &&
          other.viewingImageUrls == this.viewingImageUrls);
}

class ChatThreadsCompanion extends UpdateCompanion<ChatThreadRow> {
  final Value<String> id;
  final Value<String> whoSent;
  final Value<String> whoReceived;
  final Value<String?> hisName;
  final Value<String?> hisPhotoUrl;
  final Value<String?> lastMessage;
  final Value<DateTime> timeStamp;
  final Value<String?> messageType;
  final Value<String?> lastMessageId;
  final Value<String?> unreadCountJson;
  final Value<String?> generalNote;
  final Value<List<String>> generalImageUrls;
  final Value<List<DateTime>> viewingTimes;
  final Value<List<String>> viewingNotes;
  final Value<List<String>> viewingImageUrls;
  final Value<int> rowid;
  const ChatThreadsCompanion({
    this.id = const Value.absent(),
    this.whoSent = const Value.absent(),
    this.whoReceived = const Value.absent(),
    this.hisName = const Value.absent(),
    this.hisPhotoUrl = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.timeStamp = const Value.absent(),
    this.messageType = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.unreadCountJson = const Value.absent(),
    this.generalNote = const Value.absent(),
    this.generalImageUrls = const Value.absent(),
    this.viewingTimes = const Value.absent(),
    this.viewingNotes = const Value.absent(),
    this.viewingImageUrls = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatThreadsCompanion.insert({
    required String id,
    required String whoSent,
    required String whoReceived,
    this.hisName = const Value.absent(),
    this.hisPhotoUrl = const Value.absent(),
    this.lastMessage = const Value.absent(),
    required DateTime timeStamp,
    this.messageType = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.unreadCountJson = const Value.absent(),
    this.generalNote = const Value.absent(),
    this.generalImageUrls = const Value.absent(),
    this.viewingTimes = const Value.absent(),
    this.viewingNotes = const Value.absent(),
    this.viewingImageUrls = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       whoSent = Value(whoSent),
       whoReceived = Value(whoReceived),
       timeStamp = Value(timeStamp);
  static Insertable<ChatThreadRow> custom({
    Expression<String>? id,
    Expression<String>? whoSent,
    Expression<String>? whoReceived,
    Expression<String>? hisName,
    Expression<String>? hisPhotoUrl,
    Expression<String>? lastMessage,
    Expression<DateTime>? timeStamp,
    Expression<String>? messageType,
    Expression<String>? lastMessageId,
    Expression<String>? unreadCountJson,
    Expression<String>? generalNote,
    Expression<String>? generalImageUrls,
    Expression<String>? viewingTimes,
    Expression<String>? viewingNotes,
    Expression<String>? viewingImageUrls,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (whoSent != null) 'who_sent': whoSent,
      if (whoReceived != null) 'who_received': whoReceived,
      if (hisName != null) 'his_name': hisName,
      if (hisPhotoUrl != null) 'his_photo_url': hisPhotoUrl,
      if (lastMessage != null) 'last_message': lastMessage,
      if (timeStamp != null) 'time_stamp': timeStamp,
      if (messageType != null) 'message_type': messageType,
      if (lastMessageId != null) 'last_message_id': lastMessageId,
      if (unreadCountJson != null) 'unread_count_json': unreadCountJson,
      if (generalNote != null) 'general_note': generalNote,
      if (generalImageUrls != null) 'general_image_urls': generalImageUrls,
      if (viewingTimes != null) 'viewing_times': viewingTimes,
      if (viewingNotes != null) 'viewing_notes': viewingNotes,
      if (viewingImageUrls != null) 'viewing_image_urls': viewingImageUrls,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatThreadsCompanion copyWith({
    Value<String>? id,
    Value<String>? whoSent,
    Value<String>? whoReceived,
    Value<String?>? hisName,
    Value<String?>? hisPhotoUrl,
    Value<String?>? lastMessage,
    Value<DateTime>? timeStamp,
    Value<String?>? messageType,
    Value<String?>? lastMessageId,
    Value<String?>? unreadCountJson,
    Value<String?>? generalNote,
    Value<List<String>>? generalImageUrls,
    Value<List<DateTime>>? viewingTimes,
    Value<List<String>>? viewingNotes,
    Value<List<String>>? viewingImageUrls,
    Value<int>? rowid,
  }) {
    return ChatThreadsCompanion(
      id: id ?? this.id,
      whoSent: whoSent ?? this.whoSent,
      whoReceived: whoReceived ?? this.whoReceived,
      hisName: hisName ?? this.hisName,
      hisPhotoUrl: hisPhotoUrl ?? this.hisPhotoUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      timeStamp: timeStamp ?? this.timeStamp,
      messageType: messageType ?? this.messageType,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      unreadCountJson: unreadCountJson ?? this.unreadCountJson,
      generalNote: generalNote ?? this.generalNote,
      generalImageUrls: generalImageUrls ?? this.generalImageUrls,
      viewingTimes: viewingTimes ?? this.viewingTimes,
      viewingNotes: viewingNotes ?? this.viewingNotes,
      viewingImageUrls: viewingImageUrls ?? this.viewingImageUrls,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (whoSent.present) {
      map['who_sent'] = Variable<String>(whoSent.value);
    }
    if (whoReceived.present) {
      map['who_received'] = Variable<String>(whoReceived.value);
    }
    if (hisName.present) {
      map['his_name'] = Variable<String>(hisName.value);
    }
    if (hisPhotoUrl.present) {
      map['his_photo_url'] = Variable<String>(hisPhotoUrl.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (timeStamp.present) {
      map['time_stamp'] = Variable<DateTime>(timeStamp.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (lastMessageId.present) {
      map['last_message_id'] = Variable<String>(lastMessageId.value);
    }
    if (unreadCountJson.present) {
      map['unread_count_json'] = Variable<String>(unreadCountJson.value);
    }
    if (generalNote.present) {
      map['general_note'] = Variable<String>(generalNote.value);
    }
    if (generalImageUrls.present) {
      map['general_image_urls'] = Variable<String>(
        $ChatThreadsTable.$convertergeneralImageUrls.toSql(
          generalImageUrls.value,
        ),
      );
    }
    if (viewingTimes.present) {
      map['viewing_times'] = Variable<String>(
        $ChatThreadsTable.$converterviewingTimes.toSql(viewingTimes.value),
      );
    }
    if (viewingNotes.present) {
      map['viewing_notes'] = Variable<String>(
        $ChatThreadsTable.$converterviewingNotes.toSql(viewingNotes.value),
      );
    }
    if (viewingImageUrls.present) {
      map['viewing_image_urls'] = Variable<String>(
        $ChatThreadsTable.$converterviewingImageUrls.toSql(
          viewingImageUrls.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatThreadsCompanion(')
          ..write('id: $id, ')
          ..write('whoSent: $whoSent, ')
          ..write('whoReceived: $whoReceived, ')
          ..write('hisName: $hisName, ')
          ..write('hisPhotoUrl: $hisPhotoUrl, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('timeStamp: $timeStamp, ')
          ..write('messageType: $messageType, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('unreadCountJson: $unreadCountJson, ')
          ..write('generalNote: $generalNote, ')
          ..write('generalImageUrls: $generalImageUrls, ')
          ..write('viewingTimes: $viewingTimes, ')
          ..write('viewingNotes: $viewingNotes, ')
          ..write('viewingImageUrls: $viewingImageUrls, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BlockedUsersTable extends BlockedUsers
    with TableInfo<$BlockedUsersTable, BlockedUserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlockedUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'blocked_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<BlockedUserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  BlockedUserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlockedUserRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
    );
  }

  @override
  $BlockedUsersTable createAlias(String alias) {
    return $BlockedUsersTable(attachedDatabase, alias);
  }
}

class BlockedUserRow extends DataClass implements Insertable<BlockedUserRow> {
  final String userId;
  const BlockedUserRow({required this.userId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    return map;
  }

  BlockedUsersCompanion toCompanion(bool nullToAbsent) {
    return BlockedUsersCompanion(userId: Value(userId));
  }

  factory BlockedUserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlockedUserRow(userId: serializer.fromJson<String>(json['userId']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'userId': serializer.toJson<String>(userId)};
  }

  BlockedUserRow copyWith({String? userId}) =>
      BlockedUserRow(userId: userId ?? this.userId);
  BlockedUserRow copyWithCompanion(BlockedUsersCompanion data) {
    return BlockedUserRow(
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlockedUserRow(')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => userId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlockedUserRow && other.userId == this.userId);
}

class BlockedUsersCompanion extends UpdateCompanion<BlockedUserRow> {
  final Value<String> userId;
  final Value<int> rowid;
  const BlockedUsersCompanion({
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BlockedUsersCompanion.insert({
    required String userId,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<BlockedUserRow> custom({
    Expression<String>? userId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BlockedUsersCompanion copyWith({Value<String>? userId, Value<int>? rowid}) {
    return BlockedUsersCompanion(
      userId: userId ?? this.userId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlockedUsersCompanion(')
          ..write('userId: $userId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ChatThreadsTable chatThreads = $ChatThreadsTable(this);
  late final $BlockedUsersTable blockedUsers = $BlockedUsersTable(this);
  late final ChatDao chatDao = ChatDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    messages,
    chatThreads,
    blockedUsers,
  ];
}

typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      required String messageId,
      required String chatRoomId,
      required String whoSent,
      required String whoReceived,
      required bool isOutgoing,
      Value<String?> messageText,
      required String messageType,
      Value<String> operation,
      Value<String> status,
      Value<bool> isRead,
      required DateTime timestamp,
      Value<DateTime?> editedAt,
      Value<String?> localPath,
      Value<String?> remoteUrl,
      Value<String?> thumbnailPath,
      Value<int?> replyToMessageId,
      Value<String?> repliedToMessageText,
      Value<String?> repliedToWhoSent,
      Value<String?> repliedToMessageId,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      Value<String> messageId,
      Value<String> chatRoomId,
      Value<String> whoSent,
      Value<String> whoReceived,
      Value<bool> isOutgoing,
      Value<String?> messageText,
      Value<String> messageType,
      Value<String> operation,
      Value<String> status,
      Value<bool> isRead,
      Value<DateTime> timestamp,
      Value<DateTime?> editedAt,
      Value<String?> localPath,
      Value<String?> remoteUrl,
      Value<String?> thumbnailPath,
      Value<int?> replyToMessageId,
      Value<String?> repliedToMessageText,
      Value<String?> repliedToWhoSent,
      Value<String?> repliedToMessageId,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatRoomId => $composableBuilder(
    column: $table.chatRoomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whoSent => $composableBuilder(
    column: $table.whoSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whoReceived => $composableBuilder(
    column: $table.whoReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageText => $composableBuilder(
    column: $table.messageText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replyToMessageId => $composableBuilder(
    column: $table.replyToMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repliedToMessageText => $composableBuilder(
    column: $table.repliedToMessageText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repliedToWhoSent => $composableBuilder(
    column: $table.repliedToWhoSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repliedToMessageId => $composableBuilder(
    column: $table.repliedToMessageId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatRoomId => $composableBuilder(
    column: $table.chatRoomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whoSent => $composableBuilder(
    column: $table.whoSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whoReceived => $composableBuilder(
    column: $table.whoReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageText => $composableBuilder(
    column: $table.messageText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replyToMessageId => $composableBuilder(
    column: $table.replyToMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repliedToMessageText => $composableBuilder(
    column: $table.repliedToMessageText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repliedToWhoSent => $composableBuilder(
    column: $table.repliedToWhoSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repliedToMessageId => $composableBuilder(
    column: $table.repliedToMessageId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get chatRoomId => $composableBuilder(
    column: $table.chatRoomId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whoSent =>
      $composableBuilder(column: $table.whoSent, builder: (column) => column);

  GeneratedColumn<String> get whoReceived => $composableBuilder(
    column: $table.whoReceived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageText => $composableBuilder(
    column: $table.messageText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get replyToMessageId => $composableBuilder(
    column: $table.replyToMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repliedToMessageText => $composableBuilder(
    column: $table.repliedToMessageText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repliedToWhoSent => $composableBuilder(
    column: $table.repliedToWhoSent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repliedToMessageId => $composableBuilder(
    column: $table.repliedToMessageId,
    builder: (column) => column,
  );
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          MessageRow,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (
            MessageRow,
            BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>,
          ),
          MessageRow,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> chatRoomId = const Value.absent(),
                Value<String> whoSent = const Value.absent(),
                Value<String> whoReceived = const Value.absent(),
                Value<bool> isOutgoing = const Value.absent(),
                Value<String?> messageText = const Value.absent(),
                Value<String> messageType = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int?> replyToMessageId = const Value.absent(),
                Value<String?> repliedToMessageText = const Value.absent(),
                Value<String?> repliedToWhoSent = const Value.absent(),
                Value<String?> repliedToMessageId = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                messageId: messageId,
                chatRoomId: chatRoomId,
                whoSent: whoSent,
                whoReceived: whoReceived,
                isOutgoing: isOutgoing,
                messageText: messageText,
                messageType: messageType,
                operation: operation,
                status: status,
                isRead: isRead,
                timestamp: timestamp,
                editedAt: editedAt,
                localPath: localPath,
                remoteUrl: remoteUrl,
                thumbnailPath: thumbnailPath,
                replyToMessageId: replyToMessageId,
                repliedToMessageText: repliedToMessageText,
                repliedToWhoSent: repliedToWhoSent,
                repliedToMessageId: repliedToMessageId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageId,
                required String chatRoomId,
                required String whoSent,
                required String whoReceived,
                required bool isOutgoing,
                Value<String?> messageText = const Value.absent(),
                required String messageType,
                Value<String> operation = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                required DateTime timestamp,
                Value<DateTime?> editedAt = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int?> replyToMessageId = const Value.absent(),
                Value<String?> repliedToMessageText = const Value.absent(),
                Value<String?> repliedToWhoSent = const Value.absent(),
                Value<String?> repliedToMessageId = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                messageId: messageId,
                chatRoomId: chatRoomId,
                whoSent: whoSent,
                whoReceived: whoReceived,
                isOutgoing: isOutgoing,
                messageText: messageText,
                messageType: messageType,
                operation: operation,
                status: status,
                isRead: isRead,
                timestamp: timestamp,
                editedAt: editedAt,
                localPath: localPath,
                remoteUrl: remoteUrl,
                thumbnailPath: thumbnailPath,
                replyToMessageId: replyToMessageId,
                repliedToMessageText: repliedToMessageText,
                repliedToWhoSent: repliedToWhoSent,
                repliedToMessageId: repliedToMessageId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      MessageRow,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (MessageRow, BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>),
      MessageRow,
      PrefetchHooks Function()
    >;
typedef $$ChatThreadsTableCreateCompanionBuilder =
    ChatThreadsCompanion Function({
      required String id,
      required String whoSent,
      required String whoReceived,
      Value<String?> hisName,
      Value<String?> hisPhotoUrl,
      Value<String?> lastMessage,
      required DateTime timeStamp,
      Value<String?> messageType,
      Value<String?> lastMessageId,
      Value<String?> unreadCountJson,
      Value<String?> generalNote,
      Value<List<String>> generalImageUrls,
      Value<List<DateTime>> viewingTimes,
      Value<List<String>> viewingNotes,
      Value<List<String>> viewingImageUrls,
      Value<int> rowid,
    });
typedef $$ChatThreadsTableUpdateCompanionBuilder =
    ChatThreadsCompanion Function({
      Value<String> id,
      Value<String> whoSent,
      Value<String> whoReceived,
      Value<String?> hisName,
      Value<String?> hisPhotoUrl,
      Value<String?> lastMessage,
      Value<DateTime> timeStamp,
      Value<String?> messageType,
      Value<String?> lastMessageId,
      Value<String?> unreadCountJson,
      Value<String?> generalNote,
      Value<List<String>> generalImageUrls,
      Value<List<DateTime>> viewingTimes,
      Value<List<String>> viewingNotes,
      Value<List<String>> viewingImageUrls,
      Value<int> rowid,
    });

class $$ChatThreadsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatThreadsTable> {
  $$ChatThreadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whoSent => $composableBuilder(
    column: $table.whoSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whoReceived => $composableBuilder(
    column: $table.whoReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hisName => $composableBuilder(
    column: $table.hisName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hisPhotoUrl => $composableBuilder(
    column: $table.hisPhotoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timeStamp => $composableBuilder(
    column: $table.timeStamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unreadCountJson => $composableBuilder(
    column: $table.unreadCountJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get generalNote => $composableBuilder(
    column: $table.generalNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get generalImageUrls => $composableBuilder(
    column: $table.generalImageUrls,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<DateTime>, List<DateTime>, String>
  get viewingTimes => $composableBuilder(
    column: $table.viewingTimes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get viewingNotes => $composableBuilder(
    column: $table.viewingNotes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get viewingImageUrls => $composableBuilder(
    column: $table.viewingImageUrls,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$ChatThreadsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatThreadsTable> {
  $$ChatThreadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whoSent => $composableBuilder(
    column: $table.whoSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whoReceived => $composableBuilder(
    column: $table.whoReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hisName => $composableBuilder(
    column: $table.hisName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hisPhotoUrl => $composableBuilder(
    column: $table.hisPhotoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timeStamp => $composableBuilder(
    column: $table.timeStamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unreadCountJson => $composableBuilder(
    column: $table.unreadCountJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get generalNote => $composableBuilder(
    column: $table.generalNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get generalImageUrls => $composableBuilder(
    column: $table.generalImageUrls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewingTimes => $composableBuilder(
    column: $table.viewingTimes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewingNotes => $composableBuilder(
    column: $table.viewingNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewingImageUrls => $composableBuilder(
    column: $table.viewingImageUrls,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatThreadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatThreadsTable> {
  $$ChatThreadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get whoSent =>
      $composableBuilder(column: $table.whoSent, builder: (column) => column);

  GeneratedColumn<String> get whoReceived => $composableBuilder(
    column: $table.whoReceived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hisName =>
      $composableBuilder(column: $table.hisName, builder: (column) => column);

  GeneratedColumn<String> get hisPhotoUrl => $composableBuilder(
    column: $table.hisPhotoUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timeStamp =>
      $composableBuilder(column: $table.timeStamp, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unreadCountJson => $composableBuilder(
    column: $table.unreadCountJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get generalNote => $composableBuilder(
    column: $table.generalNote,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get generalImageUrls =>
      $composableBuilder(
        column: $table.generalImageUrls,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<DateTime>, String> get viewingTimes =>
      $composableBuilder(
        column: $table.viewingTimes,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get viewingNotes =>
      $composableBuilder(
        column: $table.viewingNotes,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get viewingImageUrls =>
      $composableBuilder(
        column: $table.viewingImageUrls,
        builder: (column) => column,
      );
}

class $$ChatThreadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatThreadsTable,
          ChatThreadRow,
          $$ChatThreadsTableFilterComposer,
          $$ChatThreadsTableOrderingComposer,
          $$ChatThreadsTableAnnotationComposer,
          $$ChatThreadsTableCreateCompanionBuilder,
          $$ChatThreadsTableUpdateCompanionBuilder,
          (
            ChatThreadRow,
            BaseReferences<_$AppDatabase, $ChatThreadsTable, ChatThreadRow>,
          ),
          ChatThreadRow,
          PrefetchHooks Function()
        > {
  $$ChatThreadsTableTableManager(_$AppDatabase db, $ChatThreadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatThreadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatThreadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatThreadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> whoSent = const Value.absent(),
                Value<String> whoReceived = const Value.absent(),
                Value<String?> hisName = const Value.absent(),
                Value<String?> hisPhotoUrl = const Value.absent(),
                Value<String?> lastMessage = const Value.absent(),
                Value<DateTime> timeStamp = const Value.absent(),
                Value<String?> messageType = const Value.absent(),
                Value<String?> lastMessageId = const Value.absent(),
                Value<String?> unreadCountJson = const Value.absent(),
                Value<String?> generalNote = const Value.absent(),
                Value<List<String>> generalImageUrls = const Value.absent(),
                Value<List<DateTime>> viewingTimes = const Value.absent(),
                Value<List<String>> viewingNotes = const Value.absent(),
                Value<List<String>> viewingImageUrls = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatThreadsCompanion(
                id: id,
                whoSent: whoSent,
                whoReceived: whoReceived,
                hisName: hisName,
                hisPhotoUrl: hisPhotoUrl,
                lastMessage: lastMessage,
                timeStamp: timeStamp,
                messageType: messageType,
                lastMessageId: lastMessageId,
                unreadCountJson: unreadCountJson,
                generalNote: generalNote,
                generalImageUrls: generalImageUrls,
                viewingTimes: viewingTimes,
                viewingNotes: viewingNotes,
                viewingImageUrls: viewingImageUrls,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String whoSent,
                required String whoReceived,
                Value<String?> hisName = const Value.absent(),
                Value<String?> hisPhotoUrl = const Value.absent(),
                Value<String?> lastMessage = const Value.absent(),
                required DateTime timeStamp,
                Value<String?> messageType = const Value.absent(),
                Value<String?> lastMessageId = const Value.absent(),
                Value<String?> unreadCountJson = const Value.absent(),
                Value<String?> generalNote = const Value.absent(),
                Value<List<String>> generalImageUrls = const Value.absent(),
                Value<List<DateTime>> viewingTimes = const Value.absent(),
                Value<List<String>> viewingNotes = const Value.absent(),
                Value<List<String>> viewingImageUrls = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatThreadsCompanion.insert(
                id: id,
                whoSent: whoSent,
                whoReceived: whoReceived,
                hisName: hisName,
                hisPhotoUrl: hisPhotoUrl,
                lastMessage: lastMessage,
                timeStamp: timeStamp,
                messageType: messageType,
                lastMessageId: lastMessageId,
                unreadCountJson: unreadCountJson,
                generalNote: generalNote,
                generalImageUrls: generalImageUrls,
                viewingTimes: viewingTimes,
                viewingNotes: viewingNotes,
                viewingImageUrls: viewingImageUrls,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatThreadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatThreadsTable,
      ChatThreadRow,
      $$ChatThreadsTableFilterComposer,
      $$ChatThreadsTableOrderingComposer,
      $$ChatThreadsTableAnnotationComposer,
      $$ChatThreadsTableCreateCompanionBuilder,
      $$ChatThreadsTableUpdateCompanionBuilder,
      (
        ChatThreadRow,
        BaseReferences<_$AppDatabase, $ChatThreadsTable, ChatThreadRow>,
      ),
      ChatThreadRow,
      PrefetchHooks Function()
    >;
typedef $$BlockedUsersTableCreateCompanionBuilder =
    BlockedUsersCompanion Function({required String userId, Value<int> rowid});
typedef $$BlockedUsersTableUpdateCompanionBuilder =
    BlockedUsersCompanion Function({Value<String> userId, Value<int> rowid});

class $$BlockedUsersTableFilterComposer
    extends Composer<_$AppDatabase, $BlockedUsersTable> {
  $$BlockedUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BlockedUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $BlockedUsersTable> {
  $$BlockedUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BlockedUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $BlockedUsersTable> {
  $$BlockedUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);
}

class $$BlockedUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BlockedUsersTable,
          BlockedUserRow,
          $$BlockedUsersTableFilterComposer,
          $$BlockedUsersTableOrderingComposer,
          $$BlockedUsersTableAnnotationComposer,
          $$BlockedUsersTableCreateCompanionBuilder,
          $$BlockedUsersTableUpdateCompanionBuilder,
          (
            BlockedUserRow,
            BaseReferences<_$AppDatabase, $BlockedUsersTable, BlockedUserRow>,
          ),
          BlockedUserRow,
          PrefetchHooks Function()
        > {
  $$BlockedUsersTableTableManager(_$AppDatabase db, $BlockedUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlockedUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlockedUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlockedUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BlockedUsersCompanion(userId: userId, rowid: rowid),
          createCompanionCallback:
              ({
                required String userId,
                Value<int> rowid = const Value.absent(),
              }) => BlockedUsersCompanion.insert(userId: userId, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BlockedUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BlockedUsersTable,
      BlockedUserRow,
      $$BlockedUsersTableFilterComposer,
      $$BlockedUsersTableOrderingComposer,
      $$BlockedUsersTableAnnotationComposer,
      $$BlockedUsersTableCreateCompanionBuilder,
      $$BlockedUsersTableUpdateCompanionBuilder,
      (
        BlockedUserRow,
        BaseReferences<_$AppDatabase, $BlockedUsersTable, BlockedUserRow>,
      ),
      BlockedUserRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ChatThreadsTableTableManager get chatThreads =>
      $$ChatThreadsTableTableManager(_db, _db.chatThreads);
  $$BlockedUsersTableTableManager get blockedUsers =>
      $$BlockedUsersTableTableManager(_db, _db.blockedUsers);
}

mixin _$ChatDaoMixin on DatabaseAccessor<AppDatabase> {
  $MessagesTable get messages => attachedDatabase.messages;
  $ChatThreadsTable get chatThreads => attachedDatabase.chatThreads;
  $BlockedUsersTable get blockedUsers => attachedDatabase.blockedUsers;
}
