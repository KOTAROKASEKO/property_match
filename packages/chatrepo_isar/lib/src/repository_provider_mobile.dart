
import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'chat_repository_mobile.dart';

ChatRepository getPlatformRepository() {
  print('[Repository Provider] Creating IsarChatRepository for Mobile.');
  
  return IsarChatRepository();
}