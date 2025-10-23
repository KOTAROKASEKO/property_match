//DEFINTION CLASS

import 'package:re_conver/1-mobile-lib/data/chat_thread.dart';
import 'package:re_conver/1-mobile-lib/data/message_model.dart';



abstract class ChatRepository {
  Future<void> init();
  Future<void> createMessage(MessageModel message);
  Future<List<MessageModel>> getMessagesForChatRoom(String chatRoomId, {int limit = 20, int offset = 0});
  Future<void> createOrUpdateMessage(MessageModel message);
  Future<void> deleteMessageForEveryone(MessageModel message);

  Future<void> saveChatThread(ChatThread thread);
  Stream<List<ChatThread>> watchChatThreads();
  Future<void> deleteChatThreadAndMessages(String threadId);

  Future<List<String>> getBlockedUsers();
  Future<void> addToBlockedUsers(String blockedUser);
  Future<void> removeFromBlockedUsers(String blockedUser);

  Future<void> clearDatabaseOnLogout();
}