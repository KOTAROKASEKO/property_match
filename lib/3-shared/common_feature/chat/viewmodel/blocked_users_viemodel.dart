// common_feature/chat/viewmodel/blocked_users_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../data/local/chat_repository.dart';
import '../data/repository_provider.dart';
import 'chat_service.dart';

class BlockedUsersViewModel extends ChangeNotifier {
  late ChatRepository chatRepo;
  final ChatService _chatService = ChatService();

  List<String> _blockedUsers = [];
  List<String> get blockedUsers => _blockedUsers;

  bool _isLoading = false;
  
  bool _isUnblocking = false;
  bool get isUnblocking => _isUnblocking;

  bool get isLoading => _isLoading;

  BlockedUsersViewModel() {
    chatRepo = getChatRepository();
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers() async {
    _isLoading = true;
    notifyListeners();
    _blockedUsers = await chatRepo.getBlockedUsers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> unblockUser(String userId) async {
    try {
      _isUnblocking  = true;
      notifyListeners();
      // Unblock on the backend and local DB
      await _chatService.unblockUser(userId);
      await chatRepo.removeFromBlockedUsers(userId);
      
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