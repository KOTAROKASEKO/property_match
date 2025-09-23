// lib/2_tenant_feature/4_chat/model/chat_thread.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' hide Index;
import 'package:isar/isar.dart';

part 'chat_thread.g.dart';

@Collection()
class ChatThread {
  late String id;

  Id get isarId => fastHash(id);

  @Index()
  late String whoSent;

  @Index()
  late String whoReceived;

  String? lastMessage;
  late DateTime timeStamp;
  String? messageType;
  String? lastMessageId;

  String? unreadCountJson;

  List<DateTime> viewingTimes = []; // Store multiple viewing times
  List<String> viewingNotes = []; // Corresponding notes for each time
  List<String> viewingImageUrls = []; // This will now store JSON strings of image lists

  @ignore
  Map<String, int> get unreadCountMap {
    if (unreadCountJson == null || unreadCountJson!.isEmpty) {
      return {};
    }
    return Map<String, int>.from(jsonDecode(unreadCountJson!));
  }

  set unreadCountMap(Map<String, int> map) {
    unreadCountJson = jsonEncode(map);
  }

  int fastHash(String string) {
    var hash = 0xcbf29ce484222325;
    var i = 0;
    while (i < string.length) {
      hash ^= string.codeUnitAt(i++);
      hash *= 0x100000001b3;
    }
    return hash;
  }

  static ChatThread fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    if (data == null) {
      throw Exception("Document data was null for doc.id: ${doc.id}");
    }

    final whoReceived = data['whoReceived'] as String;

    Map<String, int> parsedUnreadCountMap = {};
    data.forEach((key, value) {
      if (key.startsWith('unreadCount_') && value is int) {
        final userId = key.substring('unreadCount_'.length);
        parsedUnreadCountMap[userId] = value;
      }
    });

    if (data.containsKey('unreadCount') && data['unreadCount'] is int) {
      parsedUnreadCountMap.putIfAbsent(whoReceived, () => data['unreadCount']);
    }

    // --- PARSE NEW FIELDS ---
    final List<dynamic> viewingTimestamps =
        data['viewingTimes'] as List<dynamic>? ?? [];
    final List<DateTime> parsedViewingTimes = viewingTimestamps
        .where((t) => t is Timestamp)
        .map((t) => (t as Timestamp).toDate())
        .toList();
        
    final List<dynamic> notesData = data['viewingNotes'] as List<dynamic>? ?? [];
    final List<String> parsedViewingNotes =
        notesData.map((n) => n.toString()).toList();
        
      final List<dynamic> imageUrlsData =
      data['viewingImageUrls'] as List<dynamic>? ?? [];
      final List<String> parsedImageUrls = imageUrlsData.map((e) {
        if (e is List) {
          return jsonEncode(e);
        }
        return e.toString();
      }).toList();

    return ChatThread()
      ..id = doc.id
      ..whoSent = data['whoSent'] as String
      ..whoReceived = whoReceived
      ..lastMessage = data['lastMessage'] as String?
      ..timeStamp = (data['timeStamp'] as Timestamp).toDate()
      ..messageType = data['messageType'] as String?
      ..lastMessageId = data['lastMessageId'] as String?
      ..unreadCountMap = parsedUnreadCountMap
      ..viewingTimes = parsedViewingTimes
      ..viewingNotes = parsedViewingNotes
      ..viewingImageUrls = parsedImageUrls;
  }
}