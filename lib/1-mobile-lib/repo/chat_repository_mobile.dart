import 'dart:async';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:re_conver/1-mobile-lib/data/chat_thread.dart';
import 'package:re_conver/1-mobile-lib/data/message_model.dart';
import 'package:re_conver/3-shared/app/debug_print.dart';
import 'package:re_conver/3-shared/common_feature/chat/data/local/chat_repository.dart';
import '../data/blocked_model.dart';

class IsarChatRepository implements ChatRepository {
  late Future<Isar> db;

  IsarChatRepository() {
    db = openDB();
  }
  @override
  Future<void> init() async {
    await openDB(); // 既にインスタンスがあればそれを返す
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [MessageModelSchema, ChatThreadSchema, BlockedUsersModelSchema],
        inspector: true,
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }

  @override
  Future<void> createMessage(MessageModel message) async {
    final isar = await db;
    await isar.writeTxn(() => isar.messageModels.put(message));
  }

  @override
  Future<List<MessageModel>> getMessagesForChatRoom(String chatRoomId, {int limit = 20, int offset = 0}) async {
    final isar = await db;
    // .where().filter()... の Isar クエリはそのまま
    return await isar.messageModels
        .where()
        .filter()
        .chatRoomIdEqualTo(chatRoomId)
        .sortByTimestampDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  @override
  Future<void> createOrUpdateMessage(MessageModel message) async {
    final isar = await db;
    await isar.writeTxn(() async {
        // Isar では messageId をユニークキーとして putBy[IndexName] を使う
        // スキーマで messageId に @Index(unique: true, replace: true) が必要
        await isar.messageModels.putByMessageId(message);
    });
  }

   @override
  Future<void> deleteMessageForEveryone(MessageModel message) async {
    final isar = await db;
    // getByMessageId はスキーマ依存なので注意
    final messageToUpdate = await isar.messageModels.getByMessageId(message.messageId);
    if (messageToUpdate != null) {
      messageToUpdate.status = 'deleted_for_everyone';
      messageToUpdate.messageText = 'This message was deleted';
      await isar.writeTxn(() async {
        await isar.messageModels.put(messageToUpdate);
      });
    }
  }

  @override
  Future<void> saveChatThread(ChatThread thread) async {
    // ... (既存の Isar 実装) ...
    pr('[IsarRepo] Saving chatThread with id: ${thread.id}');
    final isar = await db;
    // ChatThread の isarId (getter) が Isar の ID を返すようにする
    await isar.writeTxn(() => isar.chatThreads.put(thread));
  }

  @override
  Future<void> deleteChatThreadAndMessages(String threadId) async {
    // ... (既存の Isar 実装) ...
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.messageModels.filter().chatRoomIdEqualTo(threadId).deleteAll();
      // id (Firestore ID) でフィルタリングして Isar の isarId を取得して削除
      final isarIdToDelete = await isar.chatThreads.filter().idEqualTo(threadId).isarIdProperty().findFirst();
       if (isarIdToDelete != null) {
         await isar.chatThreads.delete(isarIdToDelete);
       }
    });
  }

  // watchChatThreads は Isar 固有の watch を使うので変更が大きい
  // Stream を返すように修正が必要
  @override
  Stream<List<ChatThread>> watchChatThreads() async* {
    // ... (既存の Isar 実装を Stream を返すように修正) ...
    // yield* を使って Isar の watch 結果を流す
    final isar = await db;
    yield* isar.chatThreads.where().watch(fireImmediately: true);
     // 注意: このままではブロックユーザーのフィルタリングが適用されない
     // 必要であれば、BlockedUsersModel の watch と組み合わせてフィルタリングする Stream を作る
  }

  // _getOtherParticipantId は ViewModel 側に移動するか、ここに残すか検討
  // String _getOtherParticipantId(ChatThread thread) { ... }

  @override
  Future<void> clearDatabaseOnLogout() async {
    // ... (既存の Isar 実装) ...
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
    pr("✅ Isar database has been cleared on logout.");
  }

  @override
  Future<List<String>> getBlockedUsers() async {
    // ... (既存の Isar 実装、Firestore フォールバック含む) ...
    // ただし、Firestore へのアクセスはできれば ViewModel/Service 層で行いたい
     final isar = await db;
     final model = await isar.blockedUsersModels.get(1); // Assuming ID 1
     return model?.blockedUsers ?? []; // Firestoreへのフォールバックは削除 or ViewModelに移譲
  }

  @override
  Future<void> addToBlockedUsers(String blockedUser) async {
    // ... (既存の Isar 実装、Firestore 更新含む) ...
    // Firestore への更新も ViewModel/Service 層に移譲するのが望ましい
    final isar = await db;
    await isar.writeTxn(() async {
        final model = await isar.blockedUsersModels.get(1) ?? (BlockedUsersModel()..id = 1); // ID 1 を使う例
        // リストが growable であることを保証
        final users = List<String>.from(model.blockedUsers);
        if (!users.contains(blockedUser)) {
          users.add(blockedUser);
          model.blockedUsers = users;
          await isar.blockedUsersModels.put(model);
           // Firestore 更新はここから削除し、ViewModel/Service で行う
        }
      });
  }

  @override
  Future<void> removeFromBlockedUsers(String blockedUser) async {
    // ... (既存の Isar 実装) ...
    final isar = await db;
    await isar.writeTxn(() async {
      final model = await isar.blockedUsersModels.get(1); // Assuming ID 1
      if (model != null) {
        // リストが growable であることを保証
        final users = List<String>.from(model.blockedUsers);
        if(users.remove(blockedUser)) { // 削除されたか確認
          model.blockedUsers = users;
          await isar.blockedUsersModels.put(model);
          // Firestore 更新はここから削除し、ViewModel/Service で行う
        }
      }
    });
  }
}