// lib/3-shared/features/2_tenant_feature/2_ai_chat/viewmodel/ai_chat_viewmodel.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/3-shared/core/model/PostModel.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/model/filter_options.dart';
import 'package:shared_data/shared_data.dart'; // Required for accessing userData
import '../model/ai_chat_message.dart';
import 'ai_chat_list_viewmodel.dart';

class AIChatViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // --- Constants for Limits ---
  static const int _maxDailyMessages = 5;

  static const List<String> _developerUids = [
    'xadK5r902eaXIXQ47VifRJPepUi2', 
    'ANOTHER_DEVELOPER_UID',
  ];

  // --- State Variables ---
  String? _chatId; 
  final AIChatListViewModel _listViewModel = AIChatListViewModel();
  final List<AIChatMessage> _messages = [];
  bool _isLoading = false;
  StreamSubscription? _messageSubscription;

  // --- Getters ---
  List<AIChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get chatId => _chatId;

  // --- Constructor ---
  AIChatViewModel({String? chatId}) : _chatId = chatId {
    if (_chatId != null) {
      _listenToMessages();
    }
  }

  /// Listens to the Firestore message collection for the current chat room
  void _listenToMessages() {
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

              // Parse recommended properties if available
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

  /// Sends a user message. Returns the new chat ID if a new room was created.
  Future<String?> sendMessage(String text) async {
    if (text.trim().isEmpty) return null;

    // --- 1. Check Daily Limit ---
    final canSend = await _checkAndIncrementDailyLimit();
    if (!canSend) {
      // Add a local system message indicating the limit was reached
      _messages.add(
        AIChatMessage(
          text: "⚠️ Daily limit reached. Free users can send up to $_maxDailyMessages messages per day. Please upgrade to Premium or come back tomorrow!",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
      return null; // Stop execution
    }

    // --- 2. Proceed with Sending Message ---

    // Optimistic UI update
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

      if (_chatId == null) {
        // Create new chat room if it doesn't exist
        _chatId = await _listViewModel.createNewChatRoom(initialMessage: text);
        newChatId = _chatId;
        
        // Start listening to the new room
        _listenToMessages();
      } else {
        // Add message to existing room
        await _firestore.collection("ai_chat_messages").add({
          "chatRoomId": _chatId,
          "text": text,
          "isUser": true,
          "timestamp": FieldValue.serverTimestamp(),
          "isProcessed": false,
        });

        // Update room metadata
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

  /// Checks if the user is allowed to send a message based on daily limits,
  /// developer status, and premium status.
  Future<bool> _checkAndIncrementDailyLimit() async {
    final userId = _currentUserId;

    // 1. Developer Bypass
    if (_developerUids.contains(userId)) {
      return true; 
    }
    bool isPremiumUser = false; // Default to false for now
    if (isPremiumUser) {
      //TODO : Implement actual premium check
      return true;
    }

    // 3. Daily Limit Logic for Free Users
    final docRef = _firestore.collection('user_usage_stats').doc(userId);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    try {
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // First time user: Create record and allow
        await docRef.set({
          'dailyMessageCount': 1,
          'lastMessageDate': Timestamp.fromDate(now),
        });
        return true;
      }

      final data = docSnapshot.data()!;
      final lastDateTimestamp = data['lastMessageDate'] as Timestamp?;
      final lastDate = lastDateTimestamp?.toDate() ?? DateTime(1970);
      
      final lastDateStart = DateTime(lastDate.year, lastDate.month, lastDate.day);
      
      if (lastDateStart.isBefore(todayStart)) {
        // New day: Reset count and allow
        await docRef.update({
          'dailyMessageCount': 1,
          'lastMessageDate': Timestamp.fromDate(now),
        });
        return true;
      } else {
        // Same day: Check count
        final currentCount = data['dailyMessageCount'] as int? ?? 0;
        
        if (currentCount < _maxDailyMessages) {
          // Increment count and allow
          await docRef.update({
            'dailyMessageCount': FieldValue.increment(1),
            'lastMessageDate': Timestamp.fromDate(now),
          });
          return true;
        } else {
          // Limit exceeded: Block
          return false;
        }
      }
    } catch (e) {
      print("Error checking daily limit: $e");
      // Fail-safe: Block if error occurs to prevent abuse, or return true to allow.
      return false; 
    }
  }
  
  // Helper to get current user ID or Guest ID
  String get _currentUserId {
    if (userData.userId.isNotEmpty) {
      return userData.userId;
    } else {
      return GuestIdManager.guestId;
    }
  }

  /// Retrieves the latest filter options extracted by the AI
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