// lib/common_feature/chat/data/local/web/drift_database.dart

import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:drift/drift.dart';
import 'dart:convert';


part 'drift_database.g.dart';

// --- Type Converters ---
// DriftはデフォルトでList<String>やList<DateTime>をサポートしないため、
// JSON文字列として保存・読み込みを行うコンバータを定義します。

class JsonStringListConverter extends TypeConverter<List<String>, String> {
  const JsonStringListConverter();
  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return List<String>.from(jsonDecode(fromDb) as List);
  }

  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}

class JsonDateTimeListConverter extends TypeConverter<List<DateTime>, String> {
  const JsonDateTimeListConverter();
  @override
  List<DateTime> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final list = jsonDecode(fromDb) as List;
    return list.map((item) => DateTime.parse(item as String)).toList();
  }

  @override
  String toSql(List<DateTime> value) {
    final list = value.map((dt) => dt.toIso8601String()).toList();
    return jsonEncode(list);
  }
}

// --- Table Definitions ---

@DataClassName('MessageRow')
class Messages extends Table {
  // IsarのId autoIncrementの代わり
  IntColumn get id => integer().autoIncrement()();

  @override
  String get tableName => 'messages';

  TextColumn get messageId => text().unique()();
  TextColumn get chatRoomId => text()();
  TextColumn get whoSent => text()();
  TextColumn get whoReceived => text()();
  BoolColumn get isOutgoing => boolean()();
  TextColumn get messageText => text().nullable()();
  TextColumn get messageType => text()();
  TextColumn get operation => text().withDefault(const Constant('normal'))();
  TextColumn get status => text().withDefault(const Constant('sending'))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get timestamp => dateTime()();
  DateTimeColumn get editedAt => dateTime().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get replyToMessageId =>
      integer().nullable()(); // IsarのIdはLong (int)
  TextColumn get repliedToMessageText => text().nullable()();
  TextColumn get repliedToWhoSent => text().nullable()();
  TextColumn get repliedToMessageId => text().nullable()(); // String

  List<Index> get indexes => [
    Index('idx_messages_chatroom', 'chat_room_id'), // カラム名をStringで渡す
    Index('idx_messages_timestamp', 'timestamp'), // カラム名をStringで渡す
  ];
}

@DataClassName('ChatThreadRow')
class ChatThreads extends Table {
  // IsarのisarId (fastHash) の代わり

  @override
  Set<Column> get primaryKey => {id};


  @override
  String get tableName => 'chat_threads';

  TextColumn get id => text()();
  TextColumn get whoSent => text()();
  TextColumn get whoReceived => text()();
  TextColumn get hisName => text().nullable()();
  TextColumn get hisPhotoUrl => text().nullable()();
  TextColumn get lastMessage => text().nullable()();
  DateTimeColumn get timeStamp => dateTime()();
  TextColumn get messageType => text().nullable()();
  TextColumn get lastMessageId => text().nullable()();
  TextColumn get unreadCountJson => text().nullable()();
  TextColumn get generalNote => text().nullable()();

  TextColumn get generalImageUrls => text()
      .map(const JsonStringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get viewingTimes => text()
      .map(const JsonDateTimeListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get viewingNotes => text()
      .map(const JsonStringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get viewingImageUrls => text()
      .map(const JsonStringListConverter())
      .withDefault(const Constant('[]'))();

  List<Index> get indexes => [
    Index('idx_threads_whosent', 'who_sent'), // カラム名をStringで渡す
    Index('idx_threads_whoreceived', 'who_received'), // カラム名をStringで渡す
  ];
}

@DataClassName('BlockedUserRow')
class BlockedUsers extends Table {
  @override
  String get tableName => 'blocked_users';

  // IsarのBlockedUsersModel (Id=1) の代わり。userIdを主キーにする。
  TextColumn get userId => text()();
  @override
  Set<Column> get primaryKey => {userId};
}

// --- Database Class ---

@DriftDatabase(tables: [Messages, ChatThreads, BlockedUsers], daos: [ChatDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  // AppDatabase(super.e); // for Drift 5+

  @override
  int get schemaVersion => 1;
}

// --- DAO (Data Access Object) ---

@DriftAccessor(tables: [Messages, ChatThreads, BlockedUsers])
class ChatDao extends DatabaseAccessor<AppDatabase>
    with _$ChatDaoMixin
    implements ChatRepository {
  ChatDao(AppDatabase db) : super(db);

  // --- Model <-> DriftRow Converters ---

  MessageModel _mapRowToMessageModel(MessageRow row) {
    return MessageModel()
      ..id = row.id // DriftのAutoIncrement ID
      ..messageId = row.messageId
      ..chatRoomId = row.chatRoomId
      ..whoSent = row.whoSent
      ..whoReceived = row.whoReceived
      ..isOutgoing = row.isOutgoing
      ..messageText = row.messageText
      ..messageType = row.messageType
      ..operation = row.operation
      ..status = row.status
      ..isRead = row.isRead
      ..timestamp = row.timestamp
      ..editedAt = row.editedAt
      ..localPath = row.localPath
      ..remoteUrl = row.remoteUrl
      ..thumbnailPath = row.thumbnailPath
      ..replyToMessageId = row.replyToMessageId
      ..repliedToMessageText = row.repliedToMessageText
      ..repliedToWhoSent = row.repliedToWhoSent
      ..repliedToMessageId = row.repliedToMessageId;
  }

  MessagesCompanion _mapMessageModelToCompanion(MessageModel message) {
    return MessagesCompanion(
      // message.id (Drift ID) はInsert時には指定しない (autoIncrement)
      // Update時には Value(message.id) を含めるか、messageIdでWhereする
      messageId: Value(message.messageId),
      chatRoomId: Value(message.chatRoomId),
      whoSent: Value(message.whoSent),
      whoReceived: Value(message.whoReceived),
      isOutgoing: Value(message.isOutgoing),
      messageText: Value(message.messageText),
      messageType: Value(message.messageType),
      operation: Value(message.operation),
      status: Value(message.status),
      isRead: Value(message.isRead),
      timestamp: Value(message.timestamp),
      editedAt: Value(message.editedAt),
      localPath: Value(message.localPath),
      remoteUrl: Value(message.remoteUrl),
      thumbnailPath: Value(message.thumbnailPath),
      replyToMessageId: Value(message.replyToMessageId),
      repliedToMessageText: Value(message.repliedToMessageText),
      repliedToWhoSent: Value(message.repliedToWhoSent),
      repliedToMessageId: Value(message.repliedToMessageId),
    );
  }

  ChatThread _mapRowToChatThread(ChatThreadRow row) {

    return ChatThread()
      ..id = row.id
      ..whoSent = row.whoSent
      ..whoReceived = row.whoReceived
      ..hisName = row.hisName
      ..hisPhotoUrl = row.hisPhotoUrl
      ..lastMessage = row.lastMessage
      ..timeStamp = row.timeStamp
      ..messageType = row.messageType
      ..lastMessageId = row.lastMessageId
      ..unreadCountJson = row.unreadCountJson
      ..generalNote = row.generalNote
      ..generalImageUrls = row.generalImageUrls
      ..viewingTimes = row.viewingTimes
      ..viewingNotes = row.viewingNotes
      ..viewingImageUrls = row.viewingImageUrls;
    // isarIdはDriftのRowにマッピングしない
  }

  ChatThreadsCompanion _mapChatThreadToCompanion(ChatThread thread) {
    return ChatThreadsCompanion(
      id: Value(thread.id), // firestore ID (PK)
      whoSent: Value(thread.whoSent),
      whoReceived: Value(thread.whoReceived),
      hisName: Value(thread.hisName),
      hisPhotoUrl: Value(thread.hisPhotoUrl),
      lastMessage: Value(thread.lastMessage),
      timeStamp: Value(thread.timeStamp),
      messageType: Value(thread.messageType),
      lastMessageId: Value(thread.lastMessageId),
      unreadCountJson: Value(thread.unreadCountJson),
      generalNote: Value(thread.generalNote),
      generalImageUrls: Value(thread.generalImageUrls),
      viewingTimes: Value(thread.viewingTimes),
      viewingNotes: Value(thread.viewingNotes),
      viewingImageUrls: Value(thread.viewingImageUrls),
    );
  }

  // --- ChatRepository Implementation ---

  @override
  Future<void> init() async {
    // DriftはDBインスタンス作成時に初期化されるため、ここでは不要
    return Future.value();
  }

  @override
  Future<void> createMessage(MessageModel message) async {
    // createOrUpdateMessage で Upsert する
    await createOrUpdateMessage(message);
  }

@override
  Future<void> createOrUpdateMessage(MessageModel message) async {
    final companion = _mapMessageModelToCompanion(message);
    await into(messages).insert(companion, mode: InsertMode.replace);
  }

  @override
  Future<void> deleteMessageForEveryone(MessageModel message) async {
    // IsarChatRepository と同じ論理削除
    await (update(
      messages,
    )..where((tbl) => tbl.messageId.equals(message.messageId))).write(
      const MessagesCompanion(
        status: Value('deleted_for_everyone'),
        operation: Value('deleted'), // messageList.dart のロジックに合わせる
        messageText: Value('This message was deleted'),
        remoteUrl: Value(null), // messageList.dart のロジックに合わせる
        localPath: Value(null), // messageList.dart のロジックに合わせる
      ),
    );
  }

  @override
  Future<List<MessageModel>> getMessagesForChatRoom(
    String chatRoomId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final query = select(messages)
      ..where((tbl) => tbl.chatRoomId.equals(chatRoomId))
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc),
      ])
      ..limit(limit, offset: offset);

    final rows = await query.get();
    return rows.map(_mapRowToMessageModel).toList();
  }

  @override
  Future<void> saveChatThread(ChatThread thread) async {
    final companion = _mapChatThreadToCompanion(thread);
    // id (Firestore ID) を主キーとして Upsert
    await into(chatThreads).insertOnConflictUpdate(companion);
  }

  @override
  Stream<List<ChatThread>> watchChatThreads() {
    print('watchChatThreads called in DriftChatRepository');
    // Isarと違い、Driftではリアクティブに結合(join)するのが難しい場合がある
    // ここではまず全スレッドをwatchし、
    // ViewModel層 (例: UnreadMessagesViewModel) でブロックユーザーを
    // フィルタリングする方が簡単な場合があります。

    // もしDAOでフィルタリングする場合:
    // final blockedUsersStream = watchBlockedUsersList();
    // return blockedUsersStream.switchMap((blockedIds) {
    //   final query = select(chatThreads)
    //     ..where((t) => t.whoSent.isNotIn(blockedIds) & t.whoReceived.isNotIn(blockedIds))
    //     ..orderBy([(t) => OrderingTerm(expression: t.timeStamp, mode: OrderingMode.desc)]);
    //   return query.watch().map((rows) => rows.map(_mapRowToChatThread).toList());
    // });

    // IsarChatRepository の実装 (フィルタリングなし) に合わせる
    // Inside ChatDao watchChatThreads
  final query = select(chatThreads)
      ..orderBy([
        (t) => OrderingTerm(expression: t.timeStamp, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map(_mapRowToChatThread).toList());
  }

  // watchChatThreadsで使うための補助Stream (もしDAOでフィルタリングする場合)
  // Stream<List<String>> watchBlockedUsersList() {
  //   return select(blockedUsers).watch().map((rows) => rows.map((r) => r.userId).toList());
  // }

  @override
  Future<void> deleteChatThreadAndMessages(String threadId) async {
    await transaction(() async {
      await (delete(
        messages,
      )..where((tbl) => tbl.chatRoomId.equals(threadId))).go();
      await (delete(chatThreads)..where((tbl) => tbl.id.equals(threadId))).go();
    });
  }

  @override
  Future<void> clearDatabaseOnLogout() async {
    print('Clearing Drift database on logout...');
    await transaction(() async {
      await delete(messages).go();
      await delete(chatThreads).go();
      await delete(blockedUsers).go();
    });
    print('✅ Drift database cleared on logout');
  }

  @override
  Future<List<String>> getBlockedUsers() async {
    final rows = await select(blockedUsers).get();
    return rows.map((r) => r.userId).toList();
  }

  @override
  Future<void> addToBlockedUsers(String blockedUser) async {
    // userId を主キーとして Upsert
    await into(
      blockedUsers,
    ).insertOnConflictUpdate(BlockedUserRow(userId: blockedUser));
  }

  @override
  Future<void> removeFromBlockedUsers(String blockedUser) async {
    await (delete(
      blockedUsers,
    )..where((tbl) => tbl.userId.equals(blockedUser))).go();
  }
  
  @override
  Stream<List<String>> watchBlockedUsers() {
    // blockedUsers テーブルの変更を監視し、
    // 変更があるたびに全行を取得して List<String> に変換します
    return select(blockedUsers)
        .watch()
        .map((rows) => rows.map((row) => row.userId).toList());
  }


}
