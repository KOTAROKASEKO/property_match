// lib/common_feature/chat/data/local/web/drift_chat_repository.dart

import 'package:chatrepo_interface/chatrepo_interface.dart';

import '../src/data/drift_database.dart'; // 作成したファイルをインポート

class DriftChatRepository implements ChatRepository {
  final AppDatabase _db;
  late final ChatDao _chatDao;

  DriftChatRepository(this._db) {
    _chatDao = ChatDao(_db); // DAO を初期化
  }

  @override
  Future<void> init() async {
    // DAOに実装を移したので、DAOのinitを呼ぶ (今回は空)
    await _chatDao.init();
  }

  @override
  Future<void> createMessage(MessageModel message) async {
    await _chatDao.createMessage(message);
  }

  @override
  Future<void> createOrUpdateMessage(MessageModel message) async {
    await _chatDao.createOrUpdateMessage(message);
  }

  @override
  Future<List<MessageModel>> getMessagesForChatRoom(
    String chatRoomId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return _chatDao.getMessagesForChatRoom(
      chatRoomId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<void> deleteMessageForEveryone(MessageModel message) async {
    await _chatDao.deleteMessageForEveryone(message);
  }

  @override
  Future<void> saveChatThread(ChatThread thread) async {
    await _chatDao.saveChatThread(thread);
  }

  @override
  Stream<List<ChatThread>> watchChatThreads() {
    return _chatDao.watchChatThreads();
  }

  @override
  Future<void> deleteChatThreadAndMessages(String threadId) async {
    await _chatDao.deleteChatThreadAndMessages(threadId);
  }

  @override
  Future<void> clearDatabaseOnLogout() async {
    await _chatDao.clearDatabaseOnLogout();
  }

  @override
  Future<List<String>> getBlockedUsers() async {
    return _chatDao.getBlockedUsers();
  }

  @override
  Future<void> addToBlockedUsers(String blockedUser) async {
    await _chatDao.addToBlockedUsers(blockedUser);
    // Firestoreへの書き込みは ChatService が担当
  }

  @override
  Future<void> removeFromBlockedUsers(String blockedUser) async {
    await _chatDao.removeFromBlockedUsers(blockedUser);
    // Firestoreへの書き込みは ChatService が担当
  }
}