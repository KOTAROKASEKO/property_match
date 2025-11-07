//DEFINTION CLASS

import 'package:chatrepo_interface/chatrepo_interface.dart';

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
  Stream<List<String>> watchBlockedUsers();

  Future<void> close();
}