// common_feature/chat/viewmodel/blocked_users_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:re_conver/common_feature/chat/repo/isar_helper.dart';
import 'package:re_conver/common_feature/chat/viewmodel/chat_service.dart';

class BlockedUsersViewModel extends ChangeNotifier {
  final ChatDatabase _isarService = ChatDatabase();
  final ChatService _chatService = ChatService();

  List<String> _blockedUsers = [];
  List<String> get blockedUsers => _blockedUsers;

  bool _isLoading = false;
  
  bool _isUnblocking = false;
  bool get isUnblocking => _isUnblocking;

  bool get isLoading => _isLoading;

  BlockedUsersViewModel() {
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers() async {
    _isLoading = true;
    notifyListeners();
    _blockedUsers = await _isarService.getBlockedUsers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> unblockUser(String userId) async {
    try {
      _isUnblocking  = true;
      notifyListeners();
      // Unblock on the backend and local DB
      await _chatService.unblockUser(userId);
      await _isarService.removeFromBlockedUsers(userId);
      
      // Create a new, modifiable list for the UI state
      final updatedList = List<String>.from(_blockedUsers)..remove(userId);
      _blockedUsers = updatedList;
      _isUnblocking = false;
      notifyListeners();
    } catch (e) {
      print("Error unblocking user: $e");
      // Optionally re-throw or show an error message to the user
    }
  }
}