// lib/common_feature/chat/repo/database-web/connection.dart
import 'package:drift/drift.dart';
import 'package:drift/web.dart'; // Web用のインポート

// Web用のデータベース接続を開く関数
QueryExecutor connect() {
  return WebDatabase('chat_db');
}