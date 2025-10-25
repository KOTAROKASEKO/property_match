// lib/common_feature/chat/data/repository_provider.dart
import 'package:chatrepo_drift/chatrepo_drift.dart';
import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

ChatRepository? _cachedRepository;

// 適切なリポジトリインスタンスを取得する関数 (同期)
ChatRepository getChatRepository() {
  // キャッシュがあればそれを返す
  if (_cachedRepository != null) {
    return _cachedRepository!;
  }

  print('[Repository Provider] Initializing repository for ${kIsWeb ? "Web" : "Mobile"}...');
  _cachedRepository = getPlatformRepository();

  _cachedRepository!.init().then((_) {
     print('[Repository Provider] Repository initialization complete.');
  }).catchError((e) {
     print('[Repository Provider] Repository initialization failed: $e');
  });


  print('[Repository Provider] Returning repository instance.');
  return _cachedRepository!;
}