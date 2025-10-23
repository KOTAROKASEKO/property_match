import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/local/chat_repository.dart';
import '../data/repository_provider.dart';
import '../../../features/authentication/userdata.dart';
class UnreadMessagesViewModel extends ChangeNotifier {
  final ChatRepository chatRepo = getChatRepository();
  int _totalUnreadCount = 0;
  StreamSubscription? _threadsSubscription;

  int get totalUnreadCount => _totalUnreadCount;

  UnreadMessagesViewModel() {
    _listenToUnreadMessages();
  }

  void _listenToUnreadMessages() {
    _threadsSubscription = chatRepo.watchChatThreads().listen((threads) {
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