// lib/3-shared/features/ai_chat/service/ai_service.dart
// (新規作成)

import '../model/ai_chat_message.dart';

class AIService {
  /// AI（Geminiなど）にプロンプトを送信し、応答を取得します。
  ///
  /// [history] これまでの会話履歴
  /// [newMessage] ユーザーの新しい入力
  Future<String> getAIResponse(
    List<AIChatMessage> history,
    String newMessage,
  ) async {
    // ★★★ ここに将来的にAI API (Gemini, ChatGPTなど) へのリクエストを実装します ★★★

    // (開発用のダミー応答)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // (将来的にここで会話履歴を解析し、FilterOptionsのJSONを生成する)
    if (newMessage.contains("single room")) {
       return "Single roomですね。ご予算はいくらですか？ (ダミー応答)";
    }
    
    return "はい、どのような物件をお探しですか？ (ダミー応答)";
  }
}