// lib/chatrepo_isar.dart

// Isar のリポジトリ実装をエクスポート
export 'src/chat_repository_mobile.dart';

// Isar 固有のモデル（インターフェースに含まれていないもの）をエクスポート
export 'src/model/blocked_model.dart';
export 'src/model/user_profile.dart'; 

// モバイル用のリポジトリ取得関数 (シングルトン化などはアプリ本体側で行う)
// 例:
// import 'package:chatrepo_interface/chatrepo_interface.dart';
// import 'src/chat_repository_mobile.dart';
// ChatRepository getPlatformRepository() => IsarChatRepository();