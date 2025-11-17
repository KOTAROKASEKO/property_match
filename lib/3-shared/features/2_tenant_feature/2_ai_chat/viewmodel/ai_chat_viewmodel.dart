// lib/3-shared/features/2_tenant_feature/2_ai_chat/viewmodel/ai_chat_viewmodel.dart
import 'dart:async'; // StreamSubscription のため
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore のため
import 'package:flutter/material.dart';
import 'package:re_conver/3-shared/core/model/PostModel.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/model/filter_options.dart';
import '../model/ai_chat_message.dart';
// import '../service/ai_service.dart'; // ★ AIサービスはもう不要

// lib/3-shared/features/2_tenant_feature/2_ai_chat/viewmodel/ai_chat_viewmodel.dart
// ... (imports)

class AIChatViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _chatId; // これは「ChatRoomID」を指す

  final List<AIChatMessage> _messages = [];
  bool _isLoading = false;
  StreamSubscription? _messageSubscription;

  List<AIChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  AIChatViewModel({required String chatId}) : _chatId = chatId {
    _listenToMessages(); // Firestoreの監視を開始
  }

  /// Firestoreのメッセージコレクションを監視します
  void _listenToMessages() {
    _messageSubscription?.cancel();
    _messageSubscription = _firestore
        // ★ 修正: ai_chat_messages を参照
        .collection("ai_chat_messages")
        // ★ 修正: chatRoomId で絞り込み
        .where("chatRoomId", isEqualTo: _chatId)
        .orderBy("timestamp")
        .snapshots()
        .listen(
          (snapshot) {
            _messages.clear();

            // ★ 修正: Firestoreの履歴が本当に空の場合の挨拶は「ListViewModel」が担当
            // (この画面では不要になった)

            for (var doc in snapshot.docs) {
              final data = doc.data();

              // (PostModelへの変換ロジックは変更なし)
              List<PostModel> suggestions = [];
              if (data['recommendedProperties'] != null) {
                // ... (変換ロジック) ...
                 final List<dynamic> rawProps = data['recommendedProperties'];
                suggestions = rawProps.map((prop) {
                  final Map<String, dynamic> propMap =
                      Map<String, dynamic>.from(prop);
                  if (!propMap.containsKey('objectID')) {
                    propMap['objectID'] = prop['objectID'] ?? '';
                  }
                  return PostModel.fromAlgolia(propMap);
                }).toList();
              }

              _messages.add(
                AIChatMessage(
                  text: data['text'] ?? '',
                  isUser: data['isUser'] ?? false,
                  timestamp:
                      (data['timestamp'] as Timestamp? ?? Timestamp.now())
                          .toDate(),
                  suggestedPosts: suggestions,
                ),
              );
            }
            // ★★★ ------------------ ★★★

            _isLoading = _messages.isNotEmpty && _messages.last.isUser;
            notifyListeners();
          },
          onError: (error) {
            print("Error listening to AI chat: $error");
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// ユーザーがメッセージを送信します
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = AIChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // ★ 1. Firestore (ai_chat_messages) に書き込み (Cloud Runをトリガーする)
      await _firestore
          .collection("ai_chat_messages") // ★ 修正: コレクション名
          .add({
            "chatRoomId": _chatId, // ★ 追加: ルームID
            "text": text,
            "isUser": true,
            "timestamp": FieldValue.serverTimestamp(),
            "isProcessed": false, // ★ Cloud Runが処理するためのフラグ
          });
          
      // ★ 2. Firestore (ai_chat_rooms) の最終メッセージを更新
      await _firestore.collection("ai_chat_rooms").doc(_chatId).update({
        "lastMessageText": text,
        "lastMessageTimestamp": FieldValue.serverTimestamp(),
      });
          
      // (エラー処理は変更なし)
    } catch (e) {
      _messages.remove(userMessage);
      _messages.add(
        AIChatMessage(
          text: "メッセージの送信に失敗しました。",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Cloud Runが保存した最新の検索条件を取得します
  Future<FilterOptions?> getLatestFilterOptions() async {
    try {
      // ★ 修正: ai_chat_rooms を参照
      final doc = await _firestore.collection("ai_chat_rooms").doc(_chatId).get();
      final data = doc.data();

      if (data != null && data.containsKey("latestConditions")) {
        // (以降の変換ロジックは変更なし)
        // ...
        final conditions = data["latestConditions"] as Map<String, dynamic>;
        return FilterOptions(
          gender: conditions['gender'] as String?,
          roomType: _parseRoomType(conditions['roomType']),
          minRent: (conditions['minRent'] as num?)?.toDouble(),
          maxRent: (conditions['maxRent'] as num?)?.toDouble(),
          semanticQuery:
              conditions['query'] as String?,
          hobbies: (conditions['hobbies'] as List<dynamic>?)?.cast<String>(),
        );
      }
      return null;
    } catch (e) {
      print("Error getting latest filter options: $e");
      return null;
    }
  }

  // ( _parseRoomType, dispose は変更なし) ...
  List<String>? _parseRoomType(dynamic roomTypeData) {
    if (roomTypeData == null) return null;
    if (roomTypeData is String) {
      return [roomTypeData];
    }
    if (roomTypeData is List) {
      return roomTypeData.cast<String>();
    }
    return null;
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}