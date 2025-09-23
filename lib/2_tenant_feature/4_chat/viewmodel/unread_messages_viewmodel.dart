import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:re_conver/2_tenant_feature/4_chat/repo/isar_helper.dart';
import 'package:re_conver/authentication/userdata.dart';

class UnreadMessagesViewModel extends ChangeNotifier {
  final IsarService _isarService = IsarService();
  int _totalUnreadCount = 0;
  StreamSubscription? _threadsSubscription;

  int get totalUnreadCount => _totalUnreadCount;

  UnreadMessagesViewModel() {
    _listenToUnreadMessages();
  }

  void _listenToUnreadMessages() {
    _threadsSubscription = _isarService.watchChatThreads().listen((threads) {
      int count = 0;
      for (final thread in threads) {
        count += thread.unreadCountMap[userData.userId] ?? 0;
      }
      _totalUnreadCount = count;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _threadsSubscription?.cancel();
    super.dispose();
  }
}