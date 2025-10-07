import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:re_conver/common_feature/chat/model/blocked_model.dart';
import 'package:re_conver/common_feature/chat/model/chat_thread.dart';
import 'package:re_conver/common_feature/chat/model/message_model.dart';
import 'package:re_conver/app/debug_print.dart';
import 'package:re_conver/features/authentication/userdata.dart';

class ChatDatabase {
  late Future<Isar> db;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatDatabase() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [MessageModelSchema, ChatThreadSchema, BlockedUsersModelSchema],
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
    
    // Controller to manage the combined output stream
    final controller = StreamController<List<ChatThread>>();
    
    List<ChatThread> lastThreads = [];
    List<String> lastBlockedUsers = [];
    
    StreamSubscription? threadsSub;
    StreamSubscription? blockedSub;

    void updateFilteredList() {
      final filtered = lastThreads.where(
        (thread) => !lastBlockedUsers.contains(_getOtherParticipantId(thread))
      ).toList();
      controller.add(filtered);
    }

    threadsSub = isar.chatThreads.where().watch(fireImmediately: true).listen((threads) {
      lastThreads = threads;
      updateFilteredList();
    });

    blockedSub = isar.blockedUsersModels.where().watch(fireImmediately: true).listen((blockedModels) {
      lastBlockedUsers = blockedModels.isNotEmpty ? blockedModels.first.blockedUsers : <String>[];
      updateFilteredList();
    });

    // Yield the controller's stream
    yield* controller.stream;

    // Clean up subscriptions when the listener cancels
    await controller.close();
    await threadsSub.cancel();
    await blockedSub.cancel();
  }
  
  String _getOtherParticipantId(ChatThread thread) {
    return thread.whoReceived != userData.userId
        ? thread.whoReceived
        : thread.whoSent;
  }

  Future<void> clearDatabaseOnLogout() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.clear();
    });
    pr("✅ Isar database has been cleared on logout.");
  }

  Future<List<String>> getBlockedUsers() async {
    final isar = await db;
    // We start from Isar first. If it has data, we assume it's already in the correct (growable) format.
    final model = await isar.blockedUsersModels.get(1); // Assuming ID 1 for the singleton model
    final users = model?.blockedUsers;

    if (users != null && users.isNotEmpty) {
      // Even if Isar returns a list, let's be safe and ensure it's growable.
      return List<String>.from(users);
    }

    // If Isar is empty, fetch from Firestore
    final firestore = FirebaseFirestore.instance;
    final doc = await firestore
        .collection('blockedList')
        .doc(userData.userId)
        .get();

    if (!doc.exists || doc.data() == null) return [];

    final data = doc.data()!;
    final List<dynamic>? blockedFromFs = data['blockedUsers'];

    if (blockedFromFs == null) return [];

    // *** THE CRITICAL FIX IS HERE ***
    // Create a new growable list from the Firestore data.
    final blockedUsers = List<String>.from(blockedFromFs.cast<String>());

    // Save the fetched list to Isar for future offline access
    await isar.writeTxn(() async {
      await isar.blockedUsersModels.put(
        BlockedUsersModel()
          ..id = 1
          ..blockedUsers = blockedUsers,
      );
    });

    return blockedUsers;
  }

  Future<void> addToBlockedUsers(String blockedUser) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final model = await isar.blockedUsersModels.get(1) ?? BlockedUsersModel();
        final updatedBlockedUsers = List<String>.from(model.blockedUsers);
        if (!updatedBlockedUsers.contains(blockedUser)) {
          updatedBlockedUsers.add(blockedUser);
        }
        model.blockedUsers = updatedBlockedUsers;
        await _firestore
            .collection('blockedList')
            .doc(userData.userId)
            .set({'blockedUsers': model.blockedUsers}, SetOptions(merge: true));
      });
    } catch (e) {
      pr('Error happened in blocking user : $e');
      throw Exception('Failed to block user.');
    }
  }
  Future<void> removeFromBlockedUsers(String blockedUser) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final model = await isar.blockedUsersModels.get(1);
      if (model != null) {
        final updatedBlockedUsers = List<String>.from(model.blockedUsers);

        // 2. 新しいリストから要素を削除する
        updatedBlockedUsers.remove(blockedUser);

        // 3. 更新した新しいリストをモデルに再設定する
        model.blockedUsers = updatedBlockedUsers;
        await isar.blockedUsersModels.put(model);
      }
    });
  }
}