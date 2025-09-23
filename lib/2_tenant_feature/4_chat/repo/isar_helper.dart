import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/chat_thread.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/message_model.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/user_profile.dart';
class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [MessageModelSchema, ChatThreadSchema, UserProfileForChatSchema],
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
    final isar = await db;
    await isar.writeTxn(() => isar.chatThreads.put(thread));
  }
  
  // Future<void> clearAllChatThreads() async {
  //   final isar = await db;
  //   await isar.writeTxn(() => isar.chatThreads.clear());
  // }
  
  Future<UserProfileForChat?> getUserProfile(String userId) async {
    final isar = await db;
    return await isar.userProfileForChats.where().userIdEqualTo(userId).findFirst();
  }

  Future<void> saveUserProfile(UserProfileForChat profile) async {
    final isar = await db;
    await isar.writeTxn(() => isar.userProfileForChats.put(profile));
  }
  
  Stream<List<ChatThread>> watchChatThreads() async* {
    final isar = await db;
    yield* isar.chatThreads.where().watch(fireImmediately: true);
  }

    Future<List<ChatThread>> getAllChatThreads() async {
    final isar = await db;
    return await isar.chatThreads.where().findAll();
  }
}