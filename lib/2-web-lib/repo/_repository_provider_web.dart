import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:re_conver/3-shared/common_feature/chat/data/local/chat_repository.dart';
import '../data/drift_database.dart';
import 'drift_chat_repository.dart';

ChatRepository getPlatformRepository() {
  print('[Repository Provider] Creating DriftChatRepository for Web using WasmDatabase.open');

  final db = AppDatabase(DatabaseConnection.delayed(Future(() async { // <<<--- DatabaseConnection.delayed を使用
    final result = await WasmDatabase.open(
      databaseName: 'chat_db', // データベース名 [cite: 126]
      sqlite3Uri: Uri.parse('sqlite3.wasm'), // WASM ファイルのパス [cite: 126]
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      print('Using ${result.chosenImplementation} due to missing browser '
          'features: ${result.missingFeatures}');
    }

    return result.resolvedExecutor;
  })));

  return DriftChatRepository(db);
}