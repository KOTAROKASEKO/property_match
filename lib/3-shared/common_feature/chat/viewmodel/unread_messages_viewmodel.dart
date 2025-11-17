// lib/3-shared/common_feature/chat/viewmodel/unread_messages_viewmodel.dart

import 'dart:async';
import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_data/shared_data.dart';
import '../../repository_provider.dart';

class UnreadMessagesViewModel extends ChangeNotifier {
  final ChatRepository chatRepo = getChatRepository();
  int _totalUnreadCount = 0;
  StreamSubscription? _threadsSubscription;

  int get totalUnreadCount => _totalUnreadCount;

  UnreadMessagesViewModel() {
    _listenToUnreadMessages();
  }

  void _listenToUnreadMessages() {
    // ★ 1. ユーザーIDが空の場合はリスナーを開始しない
    if (userData.userId.isEmpty) {
      pr('[UnreadMessagesViewModel] User not logged in, skipping listener.');
      return;
    }
    
    _threadsSubscription?.cancel(); // 既存のリスナーをキャンセル
    _threadsSubscription = chatRepo.watchChatThreads().listen((threads) {
      int count = 0;
      for (final thread in threads) {
        // ★ 2. 念のため、再度ユーザーIDをチェック
        if (userData.userId.isNotEmpty) {
          count += thread.unreadCountMap[userData.userId] ?? 0;
        }
      }
      _totalUnreadCount = count;
      notifyListeners();
    });
  }

  // ★ 3. ログアウト時に呼び出すクリアメソッドを追加
  void clear() {
    pr('[UnreadMessagesViewModel] Clearing unread count and stopping listener.');
    _threadsSubscription?.cancel();
    _threadsSubscription = null;
    _totalUnreadCount = 0;
    notifyListeners();
  }

  // ★ 4. ログイン時にリスナーを再開するメソッドを追加
  void restartListener() {
    pr('[UnreadMessagesViewModel] Restarting listener (likely post-login).');
    // 内部でリスナーのキャンセルとユーザーIDチェックを行う
    _listenToUnreadMessages();
  }

  @override
  void dispose() {
    _threadsSubscription?.cancel();
    super.dispose();
  }
}