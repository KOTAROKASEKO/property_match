// packages/chatrepo_isar/lib/src/chat_repository_mobile.dart

import 'dart:async';

import 'package:chatrepo_interface/chatrepo_interface.dart' as repo_interface;
// Isar モデルのインポート (インターフェースモデルを隠す必要はありません)
import 'package:chatrepo_isar/src/model/chat_thread.dart';
import 'package:chatrepo_isar/src/model/message_model.dart'; // Isar の MessageModel を使用
import 'package:chatrepo_isar/src/model/blocked_model.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_data/shared_data.dart'; // pr() のために必要

class IsarChatRepository implements repo_interface.ChatRepository {
  late Future<Isar> db;

  IsarChatRepository() {
    db = openDB();
  }

  @override
  Future<void> init() async {
    await openDB();
  }



  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [MessageModelSchema, ChatThreadSchema, BlockedUsersModelSchema],
        inspector: true, // デバッグ用にインスペクターを有効にする
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // --- 変換ヘルパー ---

  // インターフェースモデル -> Isar モデル
  MessageModel _toIsarMessageModel(
    repo_interface.MessageModel interfaceMessage,
  ) {
    return MessageModel()
      ..messageId = interfaceMessage.messageId
      ..chatRoomId = interfaceMessage.chatRoomId
      ..whoSent = interfaceMessage.whoSent
      ..whoReceived = interfaceMessage.whoReceived
      ..isOutgoing = interfaceMessage.isOutgoing
      ..messageText = interfaceMessage.messageText
      ..messageType = interfaceMessage.messageType
      ..operation = interfaceMessage.operation
      ..status = interfaceMessage.status
      ..isRead = interfaceMessage.isRead
      ..timestamp = interfaceMessage.timestamp
      ..editedAt = interfaceMessage.editedAt
      ..localPath = interfaceMessage.localPath
      ..remoteUrl = interfaceMessage.remoteUrl
      ..thumbnailPath = interfaceMessage.thumbnailPath
      ..replyToMessageId = interfaceMessage.replyToMessageId
      ..repliedToMessageText = interfaceMessage.repliedToMessageText
      ..repliedToWhoSent = interfaceMessage.repliedToWhoSent
      ..repliedToMessageId = interfaceMessage.repliedToMessageId;
  }

  repo_interface.MessageModel _fromIsarMessageModel(MessageModel isarMessage) {
    return repo_interface.MessageModel()
      ..id = isarMessage.id
      ..messageId = isarMessage.messageId
      ..chatRoomId = isarMessage.chatRoomId
      ..whoSent = isarMessage.whoSent
      ..whoReceived = isarMessage.whoReceived
      ..isOutgoing = isarMessage.isOutgoing
      ..messageText = isarMessage.messageText
      ..messageType = isarMessage.messageType
      ..operation = isarMessage.operation
      ..status = isarMessage.status
      ..isRead = isarMessage.isRead
      ..timestamp = isarMessage.timestamp
      ..editedAt = isarMessage.editedAt
      ..localPath = isarMessage.localPath
      ..remoteUrl = isarMessage.remoteUrl
      ..thumbnailPath = isarMessage.thumbnailPath
      ..replyToMessageId = isarMessage.replyToMessageId
      ..repliedToMessageText = isarMessage.repliedToMessageText
      ..repliedToWhoSent = isarMessage.repliedToWhoSent
      ..repliedToMessageId = isarMessage.repliedToMessageId;
  }

  ChatThread _toIsarChatThread(repo_interface.ChatThread interfaceThread) {
    return ChatThread()
      ..id = interfaceThread.id
      ..whoSent = interfaceThread.whoSent
      ..whoReceived = interfaceThread.whoReceived
      ..hisName = interfaceThread.hisName
      ..hisPhotoUrl = interfaceThread.hisPhotoUrl
      ..lastMessage = interfaceThread.lastMessage
      ..timeStamp = interfaceThread.timeStamp
      ..messageType = interfaceThread.messageType
      ..lastMessageId = interfaceThread.lastMessageId
      ..unreadCountJson = interfaceThread.unreadCountJson
      ..generalNote = interfaceThread.generalNote
      ..generalImageUrls = interfaceThread.generalImageUrls
      ..viewingTimes = interfaceThread.viewingTimes
      ..viewingNotes = interfaceThread.viewingNotes
      ..viewingImageUrls = interfaceThread.viewingImageUrls;
  }

  repo_interface.ChatThread _fromIsarChatThread(ChatThread isarThread) {
    return repo_interface.ChatThread()
      ..id = isarThread.id
      ..whoSent = isarThread.whoSent
      ..whoReceived = isarThread.whoReceived
      ..hisName = isarThread.hisName
      ..hisPhotoUrl = isarThread.hisPhotoUrl
      ..lastMessage = isarThread.lastMessage
      ..timeStamp = isarThread.timeStamp
      ..messageType = isarThread.messageType
      ..lastMessageId = isarThread.lastMessageId
      ..unreadCountJson = isarThread.unreadCountJson
      ..generalNote = isarThread.generalNote
      ..generalImageUrls = isarThread.generalImageUrls
      ..viewingTimes = isarThread.viewingTimes
      ..viewingNotes = isarThread.viewingNotes
      ..viewingImageUrls = isarThread.viewingImageUrls;
  }
  // --- リポジトリメソッドの実装 ---

  @override
  Future<void> createMessage(repo_interface.MessageModel message) async {
    final isar = await db;
    final isarMessage = _toIsarMessageModel(
      message,
    ); // インターフェースモデルを Isar モデルに変換
    // Isar は独自のモデル型を期待します
    await isar.writeTxn(() => isar.messageModels.put(isarMessage));
  }

  @override
  Future<List<repo_interface.MessageModel>> getMessagesForChatRoom(
    String chatRoomId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final isar = await db;
    // Isar モデルを取得
    final isarMessages = await isar.messageModels
        .where()
        .filter()
        .chatRoomIdEqualTo(chatRoomId)
        .sortByTimestampDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
    // Isar モデルのリストをインターフェースモデルのリストに変換して返す
    return isarMessages.map(_fromIsarMessageModel).toList();
  }

  @override
  Future<void> createOrUpdateMessage(
    repo_interface.MessageModel message,
  ) async {
    final isar = await db;
    final isarMessage = _toIsarMessageModel(message); // 変換
    await isar.writeTxn(() async {
      // Isar の messageId をユニークキーとして putBy[IndexName] を使用
      await isar.messageModels.putByMessageId(isarMessage); // Isar モデルを使用
    });
  }

  @override
  Future<void> deleteMessageForEveryone(
    repo_interface.MessageModel message,
  ) async {
    // インターフェースモデルを受け取る
    final isar = await db;
    // インターフェースオブジェクトの messageId を使用して Isar オブジェクトを取得
    final messageToUpdate = await isar.messageModels.getByMessageId(
      message.messageId,
    );
    if (messageToUpdate != null) {
      messageToUpdate.status = 'deleted_for_everyone';
      messageToUpdate.operation = 'deleted'; // 削除済みとしてマーク (UIロジックに合わせる)
      messageToUpdate.messageText = 'This message was deleted';
      messageToUpdate.remoteUrl = null; // 必要に応じて他のフィールドもクリア
      messageToUpdate.localPath = null;
      await isar.writeTxn(() async {
        await isar.messageModels.put(messageToUpdate); // 更新された Isar オブジェクトを保存
      });
    }
  }

  @override
  Future<void> saveChatThread(repo_interface.ChatThread thread) async {
    // インターフェースモデルを受け取る
    final isar = await db;
    final isarThread = _toIsarChatThread(thread); // 変換
    pr('[IsarRepo] Saving chatThread with id: ${isarThread.id}');
    // ChatThread の isarId (getter) が Isar の ID を返すようにします
    await isar.writeTxn(() => isar.chatThreads.put(isarThread)); // Isar モデルを使用
  }

  @override
  Future<void> deleteChatThreadAndMessages(String threadId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      // メッセージを削除
      await isar.messageModels.filter().chatRoomIdEqualTo(threadId).deleteAll();
      // スレッドを削除 (Isar ID を使って削除)
      // id (Firestore ID) でフィルタリングして Isar の isarId を取得
      final isarIdToDelete = await isar.chatThreads
          .filter()
          .idEqualTo(threadId)
          .isarIdProperty()
          .findFirst();
      if (isarIdToDelete != null) {
        await isar.chatThreads.delete(isarIdToDelete);
        pr(
          'Deleted chat thread with Isar ID: $isarIdToDelete (Firestore ID: $threadId)',
        );
      } else {
        pr('Could not find chat thread with Firestore ID: $threadId to delete');
      }
    });
  }

  @override
  Stream<List<repo_interface.ChatThread>> watchChatThreads() async* {
    final isar = await db;

    final blockedStream = isar.blockedUsersModels.watchObject(1, fireImmediately: true);

    final threadsStream = isar.chatThreads.where().watch(fireImmediately: true);

    List<String> currentBlocked = [];
    List<ChatThread> currentThreads = [];
    bool blockedFired = false;
    bool threadsFired = false;

    final controller = StreamController<List<repo_interface.ChatThread>>();

    void updateOutput() {
      // 両方のストリームが少なくとも1回データを流したら、フィルタリングしてyieldする
      if (blockedFired && threadsFired) {
        final filteredThreads = currentThreads
            .where(
              (thread) =>
                  !currentBlocked.contains(thread.whoSent) &&
                  !currentBlocked.contains(thread.whoReceived),
            )
            .map(_fromIsarChatThread) // Isarモデル -> インターフェースモデル
            .toList();
        
        // タイムスタンプで並び替え (Isarのwatchは順序を保証しない場合があるため)
        filteredThreads.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

        controller.add(filteredThreads);
      }
    }

    final blockedSub = blockedStream.listen((model) {
      currentBlocked = model?.blockedUsers ?? [];
      blockedFired = true;
      updateOutput();
    });

    final threadsSub = threadsStream.listen((isarThreads) {
      currentThreads = isarThreads;
      threadsFired = true;
      updateOutput();
    });

    // このStreamがキャンセルされたら、内部のStreamもキャンセルする
    controller.onCancel = () {
      blockedSub.cancel();
      threadsSub.cancel();
    };

    // コントローラーのStreamをyield*する
    yield* controller.stream;
    // --- ▲▲▲ 修正完了 ▲▲▲ ---
  }
  
  @override
  Future<List<String>> getBlockedUsers() async {
    final isar = await db;
    // ID 1 を使用すると仮定 (シングルトンパターン)
    final model = await isar.blockedUsersModels.get(1);
    // Firestore へのフォールバックは削除、または ViewModel/Service 層に移譲
    return model?.blockedUsers ?? [];
  }

  @override
  Future<void> addToBlockedUsers(String blockedUser) async {
    final isar = await db;
    await isar.writeTxn(() async {
      // ID 1 を使用、存在しなければ新規作成
      final model =
          await isar.blockedUsersModels.get(1) ?? (BlockedUsersModel()..id = 1);
      // リストが growable であることを保証
      final users = List<String>.from(model.blockedUsers);
      if (!users.contains(blockedUser)) {
        users.add(blockedUser);
        model.blockedUsers = users;
        await isar.blockedUsersModels.put(model);
        pr('Added $blockedUser to blocked list in Isar.');
        // Firestore 更新はここから削除し、ViewModel/Service で行う
      }
    });
  }

  @override
  Future<void> removeFromBlockedUsers(String blockedUser) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final model = await isar.blockedUsersModels.get(1); // ID 1 を使用
      if (model != null) {
        // リストが growable であることを保証
        final users = List<String>.from(model.blockedUsers);
        if (users.remove(blockedUser)) {
          // 削除されたか確認
          model.blockedUsers = users;
          await isar.blockedUsersModels.put(model);
          pr('Removed $blockedUser from blocked list in Isar.');
          // Firestore 更新はここから削除し、ViewModel/Service で行う
        }
      }
    });
  }
  
    @override
  Stream<List<String>> watchBlockedUsers() async* {
    final isar = await db;
    // BlockedUsersModel (ID=1) の変更を監視します
    await for (final model
        in isar.blockedUsersModels.watchObject(1, fireImmediately: true)) {
      if (model != null) {
        yield model.blockedUsers;
      } else {
        yield []; // ドキュメントが存在しない場合は空のリストを流します
      }
    }
  }

  @override
  Future<void> clearDatabaseOnLogout() async {
    print('🧹 Starting secure Isar database cleanup...');
    final isar = await db;
    
    // Isarの全データを削除 (Raw SQLのDELETE FROM... と同じ効果)
    await isar.writeTxn(() async {
      // Isar 3.1以降をお使いの場合、これが最も簡単です
      // await isar.clear();
      
      // Isar 3.1より前、または個別にクリアしたい場合
      await isar.chatThreads.clear();
      await isar.messageModels.clear();
      await isar.blockedUsersModels.clear();
      
      print('🧹 All Isar collections cleared.');
    });
    
    print('✅ Isar database logically cleared. Connection remains open.');
  }

  // ★★★ 2. close を実装 ★★★
  @override
  Future<void> close() async {
    final isar = await db;
    print('🔒 Closing Isar database connection from Repository.close()...');
    
    // Isarのインスタンスを閉じる
    // deleteFromDisk: false にして、データファイル自体は残します
    // (clearDatabaseOnLogoutで中身は空になっているため)
    await isar.close(deleteFromDisk: false);
    
    print('🔒 Isar database connection closed.');
  }
}
