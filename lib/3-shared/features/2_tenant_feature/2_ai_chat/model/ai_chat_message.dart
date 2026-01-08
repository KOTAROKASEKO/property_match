import '../../../../core/model/PostModel.dart'; // PostModelをインポート

class AIChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<PostModel> suggestedPosts; // ★ 追加: 提案された物件リスト

  AIChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestedPosts = const [], // デフォルトは空
  });
}