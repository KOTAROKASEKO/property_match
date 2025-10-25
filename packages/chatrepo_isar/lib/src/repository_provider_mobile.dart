// packages/chatrepo_isar/lib/src/repository_provider_mobile.dart
import 'dart:async';
import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'chat_repository_mobile.dart';
import 'model/blocked_model.dart';
import 'model/chat_thread.dart';
import 'model/message_model.dart';
import 'model/user_profile.dart';

/// モバイル (Isar) 用の getPlatformRepository 関数
ChatRepository getPlatformRepository() {
  print('[Repository Provider] Creating IsarChatRepository for Mobile.');
  
  // IsarChatRepository のコンストラクタに合わせて Isar インスタンスを非同期で開く
  final isarFuture = Future(() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [
        MessageModelSchema,
        ChatThreadSchema,
        BlockedUsersModelSchema,
        UserProfileForChatSchema,
      ],
      directory: dir.path,
      name: 'chatDbMobile', // モバイル用のDB名
    );
  });

  return IsarChatRepository();
}