// lib/3-shared/features/ai_chat/viewmodel/ai_chat_viewmodel.dart
// (新規作成)

import 'package:flutter/material.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/model/filter_options.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/2_ai_chat/model/ai_chat_message.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/2_ai_chat/service/ai_service.dart';

class AIChatViewModel extends ChangeNotifier {
  final AIService _aiService = AIService();

  final List<AIChatMessage> _messages = [];
  bool _isLoading = false;

  /// Viewが表示するメッセージのリスト
  List<AIChatMessage> get messages => _messages;
  /// AIが応答を生成中かどうか
  bool get isLoading => _isLoading;

  AIChatViewModel() {
    // 最初のAIメッセージを追加
    _messages.add(
      AIChatMessage(
        text: "こんにちは！ご希望の物件条件（場所、予算、部屋タイプなど）を教えてください。",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// ユーザーがメッセージを送信したときに呼び出されます
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. ユーザーのメッセージをリストに追加
    _messages.add(
      AIChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    _isLoading = true;
    notifyListeners();

    try {
      // 2. AIサービスに応答をリクエスト
      final aiResponse = await _aiService.getAIResponse(_messages, text);

      // 3. AIの応答をリストに追加
      _messages.add(
        AIChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      // 4. エラー処理
      _messages.add(
        AIChatMessage(
          text: "申し訳ありません、エラーが発生しました。もう一度お試しください。",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// (将来的に実装) 会話履歴から FilterOptions を生成して返します
  FilterOptions? generateFilterOptions() {
    // ★★★ ここに会話履歴を解析して FilterOptions を構築するロジックを実装 ★★★
    // 例:
    // final String? location = _findKeyInHistory("location");
    // final double? minRent = _findKeyInHistory("minRent");
    // return FilterOptions(location: location, minRent: minRent);
    
    // 今はダミーを返します
    print("（ダミー）FilterOptions を生成しました。");
    return FilterOptions(semanticQuery: "AI generated query");
  }
}