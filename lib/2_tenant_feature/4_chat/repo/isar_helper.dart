import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/chat_thread.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/message_model.dart';
import 'package:re_conver/app/debug_print.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [MessageModelSchema, ChatThreadSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> createMessage(MessageModel message) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.messageModels.putSync(message));
  }

  Future<List<MessageModel>> getMessagesForChatRoom(String chatRoomId, {int limit = 20, int offset = 0}) async {
    final isar = await db;
    return await isar.messageModels
        .where()
        .filter()
        .chatRoomIdEqualTo(chatRoomId)
        .sortByTimestampDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }
  
  Future<void> createOrUpdateMessage(MessageModel message) async {
    final isar = await db;
    await isar.writeTxn(() async {
        await isar.messageModels.putByMessageId(message);
    });
  }

  Future<void> deleteMessageForEveryone(MessageModel message) async {
    final isar = await db;
    final messageToUpdate = await isar.messageModels.getByMessageId(message.messageId);
    if (messageToUpdate != null) {
      messageToUpdate.status = 'deleted_for_everyone';
      messageToUpdate.messageText = 'This message was deleted';
      await isar.writeTxn(() async {
        await isar.messageModels.put(messageToUpdate);
      });
    }
  }

  Future<void> saveChatThread(ChatThread thread) async {
    pr('[repo] Saving chatThread with id: ${thread.id}');
    pr('[repo] His/Her name : ${thread.hisName}');
    pr('[repo] His/Her photoUrl : ${thread.hisPhotoUrl}');

    final isar = await db;
    await isar.writeTxn(() => isar.chatThreads.put(thread));
  }

  Future<void> saveAllChatThreads(List<ChatThread> threads) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.chatThreads.putAll(threads);
    });
  }

  // Add this new method inside the IsarService class

  Future<void> deleteChatThreadAndMessages(String threadId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      // First, delete all messages that belong to the chat room
      await isar.messageModels.filter().chatRoomIdEqualTo(threadId).deleteAll();
      
      // Then, find the chat thread by its unique ID and delete it
      final threadToDelete = await isar.chatThreads.filter().idEqualTo(threadId).findFirst();
      if (threadToDelete != null) {
        await isar.chatThreads.delete(threadToDelete.isarId);
      }
    });
  }
  
  Stream<List<ChatThread>> watchChatThreads() async* {
    final isar = await db;
    yield* isar.chatThreads.where().watch(fireImmediately: true);
  }

  Future<void> clearDatabaseOnLogout() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.clear();
    });
    pr("✅ Isar database has been cleared on logout.");
  }

    Future<List<ChatThread>> getAllChatThreads() async {
      pr('[repo] Fetching all chatThreads from Isar DB');
    final isar = await db;
    return await isar.chatThreads.where().findAll();
  }
}