// lib/common_feature/chat/data/repository_provider.dart
import 'platform_repository_stub.dart';
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

Future<void> disposeChatRepository() async {
  print('[Repository Provider] Disposing repository...');
  if (_cachedRepository != null) {
    try {
      // 1. リポジトリのDB接続を閉じる
      // (前提: ChatRepository インターフェースに close() メソッドが定義されている)
      await _cachedRepository!.close();
      print('[Repository Provider] Repository connection closed.');
    } catch (e) {
      print('[Repository Provider] Error closing repository. May leak connection: $e');
      // エラーが発生してもキャッシュのクリアは試みる
    }

    // 2. キャッシュを破棄する
    _cachedRepository = null;
    print('[Repository Provider] Repository cache cleared.');
  } else {
    print('[Repository Provider] Repository cache was already null.');
  }
}