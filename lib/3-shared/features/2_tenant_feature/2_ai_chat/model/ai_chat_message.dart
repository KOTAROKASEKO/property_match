// lib/3-shared/features/ai_chat/model/ai_chat_message.dart
// (新規作成)

/// AIチャット画面専用のシンプルなメッセージモデル
class AIChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AIChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}