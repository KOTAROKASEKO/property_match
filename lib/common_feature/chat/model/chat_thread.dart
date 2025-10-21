// lib/2_tenant_feature/4_chat/model/chat_thread.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' hide Index;
import 'package:isar/isar.dart';
import 'package:re_conver/features/authentication/userdata.dart';

part 'chat_thread.g.dart';

@Collection()
class ChatThread {
  
  late String id;

  Id get isarId => fastHash(id);

  @Index()
  late String whoSent;

  @Index()
  late String whoReceived;

  // New fields for the other user's details
  String? hisName;
  String? hisPhotoUrl;

  String? lastMessage;
  late DateTime timeStamp;
  String? messageType;
  String? lastMessageId;

  String? unreadCountJson;
  
  String? generalNote;
  List<String> generalImageUrls = [];

  List<DateTime> viewingTimes = [];
  List<String> viewingNotes = [];
  List<String> viewingImageUrls = [];

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
    var hash = 0xcbf29ce484222000;
    var i = 0;
    while (i < string.length) {
      hash ^= string.codeUnitAt(i++);
      hash *= 0x100000001b3;
    }
    return hash;
  }

  static ChatThread fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    String generalNotePath = userData.role == Roles.agent ? 'agentGeneralNote':'tenantGeneralNote';
    String viewingNotePath = userData.role == Roles.agent ? 'agentViewingNote':'tenantViewingNote';
    String photoImagePath = userData.role == Roles.agent ? 'agentphotoPath':'tenantPhotoPath';
    String generalphotoImagePath = userData.role == Roles.agent ? 'agentGeneralPhotoPath':'tenantGeneralPhotoPath';

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

    final List<dynamic> viewingTimestamps =
        data['viewingTimes'] as List<dynamic>? ?? [];
    final List<DateTime> parsedViewingTimes = viewingTimestamps
        .where((t) => t is Timestamp)
        .map((t) => (t as Timestamp).toDate())
        .toList();
        
    final List<dynamic> notesData = data[viewingNotePath] as List<dynamic>? ?? [];
    final List<String> parsedViewingNotes =
        notesData.map((n) => n.toString()).toList();
        
      final List<dynamic> imageUrlsData =
      data[photoImagePath] as List<dynamic>? ?? [];
      final List<String> parsedImageUrls = imageUrlsData.map((e) {
        if (e is List) {
          return jsonEncode(e);
        }
        return e.toString();
      }).toList();

    final List<dynamic> generalImageUrlsData = data[generalphotoImagePath] as List<dynamic>? ?? [];
    final List<String> parsedGeneralImageUrls = generalImageUrlsData.map((url) => url.toString()).toList();

    return ChatThread()
      ..id = doc.id
      ..whoSent = data['whoSent'] as String
      ..whoReceived = whoReceived
      ..hisName = data['hisName'] as String? // Populate new field
      ..hisPhotoUrl = data['hisPhotoUrl'] as String? // Populate new field
      ..lastMessage = data['lastMessage'] as String?
      ..timeStamp = (data['timeStamp'] as Timestamp).toDate()
      ..messageType = data['messageType'] as String?
      ..lastMessageId = data['lastMessageId'] as String?
      ..unreadCountMap = parsedUnreadCountMap
      ..generalNote = data[generalNotePath] as String?
      ..generalImageUrls = parsedGeneralImageUrls
      ..viewingTimes = parsedViewingTimes
      ..viewingNotes = parsedViewingNotes
      ..viewingImageUrls = parsedImageUrls;
  }
}