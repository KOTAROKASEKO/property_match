// lib/3-shared/features/2_tenant_feature/2_ai_chat/viewmodel/ai_chat_viewmodel.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/3-shared/core/model/PostModel.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/model/filter_options.dart';
import '../model/ai_chat_message.dart';
import 'ai_chat_list_viewmodel.dart';

class AIChatViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ★ 変更: null許容に変更 (null = 新規チャット状態)
  String? _chatId; 
  
  // ルーム作成用に ListViewModel のインスタンスを持つ
  final AIChatListViewModel _listViewModel = AIChatListViewModel();

  final List<AIChatMessage> _messages = [];
  bool _isLoading = false;
  StreamSubscription? _messageSubscription;

  List<AIChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  
  // ★ 追加: 外部からアクセスするためのゲッター
  String? get chatId => _chatId;

  // ★ 変更: コンストラクタで null を受け取れるようにする
  AIChatViewModel({String? chatId}) : _chatId = chatId {
    if (_chatId != null) {
      _listenToMessages();
    }
  }

  /// Firestoreのメッセージコレクションを監視します
  void _listenToMessages() {
    // IDがない場合は何もしない
    if (_chatId == null) return;

    _messageSubscription?.cancel();
    _messageSubscription = _firestore
        .collection("ai_chat_messages")
        .where("chatRoomId", isEqualTo: _chatId)
        .orderBy("timestamp")
        .snapshots()
        .listen(
          (snapshot) {
            _messages.clear();

            for (var doc in snapshot.docs) {
              final data = doc.data();

              List<PostModel> suggestions = [];
              if (data['recommendedProperties'] != null) {
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
  /// 戻り値: 新規作成されたチャットID (既存の場合は null)
  Future<String?> sendMessage(String text) async {
    if (text.trim().isEmpty) return null;

    // UIへの即時反映 (Optimistic UI)
    final userMessage = AIChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      String? newChatId;

      // ★ IDがない場合（新規チャット）はここで作成
      if (_chatId == null) {
        // createNewChatRoomを呼び出してルームを作成
        // ※ AIChatListViewModel側が initialMessage に対応していればそれを渡すのがベストですが、
        // 対応していない場合は空で作成後にメッセージを追加します。
        _chatId = await _listViewModel.createNewChatRoom(initialMessage: text);
        newChatId = _chatId;
        
        // 作成されたIDで監視を開始
        _listenToMessages();
      } else {
        // 既存チャットへの追加
        await _firestore.collection("ai_chat_messages").add({
          "chatRoomId": _chatId,
          "text": text,
          "isUser": true,
          "timestamp": FieldValue.serverTimestamp(),
          "isProcessed": false,
        });

        await _firestore.collection("ai_chat_rooms").doc(_chatId).update({
          "lastMessageText": text,
          "lastMessageTimestamp": FieldValue.serverTimestamp(),
        });
      }
      
      return newChatId;

    } catch (e) {
      print("Error sending message: $e");
      _messages.remove(userMessage);
      _messages.add(
        AIChatMessage(
          text: "Failed to send message. Please try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  Future<FilterOptions?> getLatestFilterOptions() async {
    if (_chatId == null) return null;
    try {
      final doc = await _firestore.collection("ai_chat_rooms").doc(_chatId).get();
      final data = doc.data();

      if (data != null && data.containsKey("latestConditions")) {
        final conditions = data["latestConditions"] as Map<String, dynamic>;
        return FilterOptions(
          gender: conditions['gender'] as String?,
          roomType: _parseRoomType(conditions['roomType']),
          minRent: (conditions['minRent'] as num?)?.toDouble(),
          maxRent: (conditions['maxRent'] as num?)?.toDouble(),
          semanticQuery: conditions['query'] as String?,
          hobbies: (conditions['hobbies'] as List<dynamic>?)?.cast<String>(),
        );
      }
      return null;
    } catch (e) {
      print("Error getting latest filter options: $e");
      return null;
    }
  }

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