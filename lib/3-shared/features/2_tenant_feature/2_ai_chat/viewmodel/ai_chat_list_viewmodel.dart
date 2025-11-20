// lib/3-shared/features/2_tenant_feature/2_ai_chat/viewmodel/ai_chat_list_viewmodel.dart
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_data/shared_data.dart';
import '../model/ai_chat_room_model.dart';

class AIChatListViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Stream<List<AIChatRoomModel>> chatRoomsStream;

  AIChatListViewModel() {
    chatRoomsStream = _getChatRoomsStream();
  }

  // AIチャットルームのリストをリアルタイムで取得
  Stream<List<AIChatRoomModel>> _getChatRoomsStream() {
    final targetUserId = _currentUserId;
    
    pr('Initializing AI Chat Stream for user: ${userData.userId}');

    return _firestore
        .collection('ai_chat_rooms')
        .where('userId', isEqualTo: targetUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AIChatRoomModel.fromFirestore(doc))
          .toList();
    });
    
  }
  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      // 1. メッセージの削除 (サブコレクションではなくトップレベルなのでクエリで取得して削除)
      final messagesSnapshot = await _firestore
          .collection('ai_chat_messages')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // 2. ルーム自体の削除
      final roomRef = _firestore.collection('ai_chat_rooms').doc(chatRoomId);
      batch.delete(roomRef);

      await batch.commit();
    } catch (e) {
      print("Error deleting chat room: $e");
      rethrow;
    }
  }
String get _currentUserId {
    if (userData.userId.isNotEmpty) {
      return userData.userId;
    } else {
      return GuestIdManager.guestId; // 先ほど定義したゲストID
    }
  }
  Future<String> createNewChatRoom() async {
    final targetUserId = _currentUserId;

    final now = Timestamp.now();
    final newChatDoc = _firestore.collection('ai_chat_rooms').doc();

    final newRoomData = {
      'userId': targetUserId,
      'title': 'New Chat - ${DateFormat.yMd().format(now.toDate())}',
      'createdAt': now,
      'lastMessageText': 'welcome to the ai agent!',
      'lastMessageTimestamp': now,
      'latestConditions': {},
    };

    await newChatDoc.set(newRoomData);
    await _firestore.collection('ai_chat_messages').add({
      'chatRoomId': newChatDoc.id,
      'text': 'hello! How may I help you?',
      'isUser': false,
      'timestamp': FieldValue.serverTimestamp(),
      'isProcessed': true,
      'recommendedProperties': [],
    });

    return newChatDoc.id;
  }
}

class GuestIdManager {
  static String? _guestId;

  static String get guestId {
    if (_guestId == null) {
      // ランダムなIDを生成 (例: guest_123456789)
      final random = Random();
      final idPart = DateTime.now().millisecondsSinceEpoch.toString() + random.nextInt(10000).toString();
      _guestId = 'guest_$idPart';
    }
    return _guestId!;
  }
}