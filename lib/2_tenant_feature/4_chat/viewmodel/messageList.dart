// lib/features/4_chat/viewmodel/messageList.dart

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/message_model.dart';
import 'package:re_conver/2_tenant_feature/4_chat/repo/isar_helper.dart';
import 'package:re_conver/2_tenant_feature/4_chat/viewmodel/chat_service.dart';
import 'package:re_conver/authentication/userdata.dart';

class MessageListProvider extends ChangeNotifier {
  final String chatThreadId;
  final String otherUserUid;

  MessageListProvider({required this.chatThreadId, required this.otherUserUid});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final IsarService _isarService = IsarService();
  StreamSubscription? _firebaseMessagesSubscription;

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  MessageModel? _editingMessage;
  bool _isLoadingMore = false;
  bool _canLoadMore = true;
  List<dynamic> _displayItems = [];
  MessageModel? _replyingToMessage;
  DocumentSnapshot? _lastVisible;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  MessageModel? get editingMessage => _editingMessage;
  bool get isLoadingMore => _isLoadingMore;
  bool get canLoadMore => _canLoadMore;
  List<dynamic> get displayItems => _displayItems;
  MessageModel? get replyingToMessage => _replyingToMessage;
  bool _shouldScrollToBottom = false;
  bool get shouldScrollToBottom => _shouldScrollToBottom;

  static const int _messagesPerPage = 20;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  void setCanLoadMore(bool canLoad) {
    _canLoadMore = canLoad;
  }

  void setSending(bool sending) {
    _isSending = sending;
    notifyListeners();
  }

  void setEditingMessage(MessageModel? message) {
    _editingMessage = message;
    notifyListeners();
  }

  void setReplyingTo(MessageModel? message) {
    _replyingToMessage = message;
    notifyListeners();
  }

  Future<void> loadMoreMessages() async {
    if (_isLoadingMore || !_canLoadMore || _lastVisible == null) return;
    setLoadingMore(true);
    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatThreadId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastVisible!)
          .limit(_messagesPerPage)
          .get();

      final olderMessages = snapshot.docs.map((doc) {
        final data = doc.data();
        final message = MessageModel()
          ..messageId = doc.id
          ..chatRoomId = chatThreadId
          ..whoSent = data['whoSentId'] as String
          ..whoReceived = data['whoReceivedId'] as String
          ..isOutgoing = (data['whoSentId'] as String) == userData.userId
          ..messageText = data['text'] as String?
          ..messageType = data['messageType'] as String
          ..operation = data['operation'] as String? ?? 'normal'
          ..status = data['status'] as String? ?? 'sent'
          ..timestamp = (data['timestamp'] as Timestamp).toDate()
          ..editedAt = data['editedAt'] == null
              ? null
              : (data['editedAt'] as Timestamp).toDate()
          ..remoteUrl = data['remoteUrl'] as String?
          ..repliedToMessageId = data['repliedToMessageId'] as String?
          ..repliedToMessageText = data['repliedToMessageText'] as String?
          ..repliedToWhoSent = data['repliedToWhoSent'] as String?;
        _isarService.createOrUpdateMessage(message); // Update local cache
        return message;
      }).toList();

      final existingMessageIds = _messages.map((m) => m.messageId).toSet();
      final uniqueOlderMessages =
          olderMessages.where((m) => !existingMessageIds.contains(m.messageId)).toList();
      _messages.addAll(uniqueOlderMessages);

      if (snapshot.docs.isNotEmpty) {
        _lastVisible = snapshot.docs.last;
      }

      _buildDisplayListWithDates();
      setCanLoadMore(olderMessages.length == _messagesPerPage);
    } catch (e) {
      print("Error loading more messages from Firestore: $e");
    } finally {
      setLoadingMore(false);
    }
  }

  void didScrollToBottom() {
    _shouldScrollToBottom = false;
  }

  Future<void> loadInitialMessages() async {
    if (_isLoading) return;
    setLoading(true);

    // 1. Load from Isar first for quick UI
    _messages = await _isarService.getMessagesForChatRoom(chatThreadId, limit: _messagesPerPage);
    _buildDisplayListWithDates();
    setLoading(false); // Show cached data immediately

    // 2. Fetch from Firestore to sync and get the pagination cursor
    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatThreadId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(_messagesPerPage)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final firestoreMessages = snapshot.docs.map((doc) {
          final data = doc.data();
          final message = MessageModel()
            ..messageId = doc.id
            ..chatRoomId = chatThreadId
            ..whoSent = data['whoSentId'] as String
            ..whoReceived = data['whoReceivedId'] as String
            ..isOutgoing = (data['whoSentId'] as String) == userData.userId
            ..messageText = data['text'] as String?
            ..messageType = data['messageType'] as String
            ..operation = data['operation'] as String? ?? 'normal'
            ..status = data['status'] as String? ?? 'sent'
            ..timestamp = (data['timestamp'] as Timestamp).toDate()
            ..editedAt = data['editedAt'] == null ? null : (data['editedAt'] as Timestamp).toDate()
            ..remoteUrl = data['remoteUrl'] as String?
            ..repliedToMessageId = data['repliedToMessageId'] as String?
            ..repliedToMessageText = data['repliedToMessageText'] as String?
            ..repliedToWhoSent = data['repliedToWhoSent'] as String?;
          _isarService.createOrUpdateMessage(message); // Update local cache
          return message;
        }).toList();
        
        _messages = firestoreMessages;
        _lastVisible = snapshot.docs.last;
        _buildDisplayListWithDates();
        setCanLoadMore(firestoreMessages.length == _messagesPerPage);
        notifyListeners(); // Update UI with fresh data
      } else {
         _canLoadMore = false;
      }
    } catch (e) {
      print("Error loading initial messages from Firestore: $e");
    }
  }

  void listenToFirebaseMessages() {
    _firebaseMessagesSubscription?.cancel();
    _firebaseMessagesSubscription = _firestore
        .collection('chats')
        .doc(chatThreadId)
        .collection('messages')
        .where('timestamp', isGreaterThan: _messages.isNotEmpty ? Timestamp.fromDate(_messages.last.timestamp) : Timestamp.fromMillisecondsSinceEpoch(0))
        .snapshots()
        .listen(
      (snapshot) async {
        if (snapshot.docChanges.isEmpty) return;

        bool requiresUIRefresh = false;
        bool newIncomingMessage = false;

        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            if (data == null) continue;

            final message = MessageModel()
              ..messageId = change.doc.id
              ..chatRoomId = chatThreadId
              ..whoSent = data['whoSentId'] as String
              ..whoReceived = data['whoReceivedId'] as String
              ..isOutgoing = (data['whoSentId'] as String) == userData.userId
              ..messageText = data['text'] as String?
              ..messageType = data['messageType'] as String
              ..operation = data['operation'] as String? ?? 'normal'
              ..status = data['status'] as String? ?? 'sent'
              ..timestamp = (data['timestamp'] as Timestamp).toDate()
              ..editedAt = data['editedAt'] == null ? null : (data['editedAt'] as Timestamp).toDate()
              ..remoteUrl = data['remoteUrl'] as String?
              ..repliedToMessageId = data['repliedToMessageId'] as String?
              ..repliedToMessageText = data['repliedToMessageText'] as String?
              ..repliedToWhoSent = data['repliedToWhoSent'] as String?;

            await _isarService.createOrUpdateMessage(message);

            final index = _messages.indexWhere((m) => m.messageId == message.messageId);
            if (index == -1) {
              _messages.add(message);
              if (!message.isOutgoing) {
                newIncomingMessage = true;
              }
              requiresUIRefresh = true;
            }
          }
        }

        if (requiresUIRefresh) {
          _buildDisplayListWithDates();
          markMessagesAsRead();
          if (newIncomingMessage) {
            _shouldScrollToBottom = true;
          }
          notifyListeners();
        }
      },
      onError: (error) {
        print("Error listening to Firebase messages: $error");
      },
    );
  }

  Future<void> sendMessage({
    String? text,
    XFile? imageFile,
    File? audioFile,
  }) async {
    if ((text == null || text.isEmpty) &&
        imageFile == null &&
        audioFile == null) return;
    if (isSending) return;

    setSending(true);
    final replyingTo = _replyingToMessage;
    if (replyingTo != null) setReplyingTo(null);

    final tempMessageId = _firestore.collection('_').doc().id;
    final now = DateTime.now();
    String messageType = 'text';
    String? localPath;
    String? lastMessageText = text;

    if (imageFile != null) {
      messageType = 'image';
      localPath = imageFile.path;
      lastMessageText = '[Image]';
    } else if (audioFile != null) {
      messageType = 'audio';
      localPath = audioFile.path;
      lastMessageText = '[Voice Message]';
    }

    MessageModel optimisticMessage = MessageModel()
      ..messageId = tempMessageId
      ..chatRoomId = chatThreadId
      ..whoSent = userData.userId
      ..whoReceived = otherUserUid
      ..isOutgoing = true
      ..messageText = text
      ..messageType = messageType
      ..status = 'sending'
      ..timestamp = now
      ..localPath = localPath
      ..repliedToMessageId = replyingTo?.messageId
      ..repliedToMessageText = _getRepliedText(replyingTo)
      ..repliedToWhoSent = replyingTo?.whoSent;

    _isarService.createMessage(optimisticMessage);
    _addOrUpdateMessage(optimisticMessage);

    try {
      String? remoteUrl;
      if (imageFile != null) {
        remoteUrl = await _uploadFileToStorage(
          File(imageFile.path),
          'chat_images/$tempMessageId',
        );
      } else if (audioFile != null) {
        remoteUrl = await _uploadFileToStorage(
          audioFile,
          'chat_audio/$tempMessageId.m4a',
        );
      }

      Map<String, dynamic> firebaseMessageData = {
        'whoSentId': userData.userId,
        'whoReceivedId': otherUserUid,
        'messageType': messageType,
        'timestamp': Timestamp.fromDate(now),
        'status': 'sent',
        'text': text,
        'remoteUrl': remoteUrl,
        'repliedToMessageId': replyingTo?.messageId,
        'repliedToMessageText': _getRepliedText(replyingTo),
        'repliedToWhoSent': replyingTo?.whoSent,
      };

      await _firestore
          .collection('chats')
          .doc(chatThreadId)
          .collection('messages')
          .doc(tempMessageId)
          .set(firebaseMessageData);

      optimisticMessage.status = 'sent';
      optimisticMessage.remoteUrl = remoteUrl;
      _isarService.createOrUpdateMessage(optimisticMessage);
      _addOrUpdateMessage(optimisticMessage);

      await _firestore.collection('chats').doc(chatThreadId).set({
        'lastMessage': lastMessageText,
        'timeStamp': Timestamp.fromDate(now),
        'whoSent': userData.userId,
        'whoReceived': otherUserUid,
        'messageType': messageType,
        'lastMessageId': tempMessageId,
        'unreadCount_${otherUserUid}': FieldValue.increment(1)
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error sending message: $e");
      optimisticMessage.status = 'failed';
      _isarService.createOrUpdateMessage(optimisticMessage);
      _addOrUpdateMessage(optimisticMessage);
    } finally {
      setSending(false);
    }
  }

  Future<void> saveEditedMessage(String editedText) async {
    if (_editingMessage == null || editedText.isEmpty) {
      setEditingMessage(null);
      return;
    }

    final messageToUpdate = _editingMessage!;
    final now = DateTime.now();
    messageToUpdate.messageText = editedText;
    messageToUpdate.editedAt = now;
    messageToUpdate.operation = 'edited';

    try {
      _isarService.createOrUpdateMessage(messageToUpdate);
      _addOrUpdateMessage(messageToUpdate);

      await _firestore
          .collection('chats')
          .doc(messageToUpdate.chatRoomId)
          .collection('messages')
          .doc(messageToUpdate.messageId)
          .update({
        'text': editedText,
        'editedAt': Timestamp.fromDate(now),
        'operation': 'edited',
      });
    } catch (e) {
      print("Error saving edited message: $e");
    } finally {
      setEditingMessage(null);
    }
  }

  void cancelEditing() {
    setEditingMessage(null);
  }

  Future<String> _uploadFileToStorage(File file, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }

  String? _getRepliedText(MessageModel? message) {
    if (message == null) return null;
    if (message.messageType == 'text') return message.messageText;
    if (message.messageType == 'image') return '[Image]';
    if (message.messageType == 'audio') return '[Voice Message]';
    return null;
  }

  Future<void> markMessagesAsRead() async {
    final unreadMessages =
        _messages.where((m) => !m.isOutgoing && !m.isRead).toList();
    if (unreadMessages.isEmpty) return;
    final batch = _firestore.batch();
    for (var message in unreadMessages) {
      message.isRead = true;
      final messageRef = _firestore
          .collection('chats')
          .doc(chatThreadId)
          .collection('messages')
          .doc(message.messageId);
      batch.update(messageRef, {'isRead': true});
    }
    final threadRef = _firestore.collection('chats').doc(chatThreadId);
    batch.update(threadRef, {'unreadCount_${userData.userId}': 0});
    await batch.commit();
    notifyListeners();
  }

  void _addOrUpdateMessage(MessageModel message) {
    final index = _messages.indexWhere((m) => m.messageId == message.messageId);
    if (index != -1) {
      _messages[index] = message;
    } else {
      _messages.add(message);
    }
    _buildDisplayListWithDates();
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _displayItems.clear();
    _editingMessage = null;
    _replyingToMessage = null;
    notifyListeners();
  }

  void _buildDisplayListWithDates() {
    if (_messages.isEmpty) {
      _displayItems = [];
      return;
    }
    List<dynamic> newDisplayList = [];
    DateTime? lastDate;

    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (var message in _messages) {
      final messageDate = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );
      if (lastDate == null || !_isSameDay(lastDate, messageDate)) {
        newDisplayList.add(messageDate);
        lastDate = messageDate;
      }
      newDisplayList.add(message);
    }
    _displayItems = newDisplayList;
  }

  bool _isSameDay(DateTime dateA, DateTime dateB) {
    return dateA.year == dateB.year &&
        dateA.month == dateB.month &&
        dateA.day == dateB.day;
  }

  @override
  void dispose() {
    _firebaseMessagesSubscription?.cancel();
    super.dispose();
  }

  Future<void> deleteMessageForEveryone(MessageModel message) async {
    // Optimistically update the UI
    final originalText = message.messageText;
    message.messageText = 'This message was deleted';
    message.status = 'deleted_for_everyone';
    _addOrUpdateMessage(message);

    try {
      // Update Firestore
      await _firestore
          .collection('chats')
          .doc(chatThreadId)
          .collection('messages')
          .doc(message.messageId)
          .update({
        'text': 'This message was deleted',
        'status': 'deleted_for_everyone',
      });

      // Update Isar
      await _isarService.deleteMessageForEveryone(message);
    } catch (e) {
      // Rollback UI on failure
      message.messageText = originalText;
      message.status = 'sent';
      _addOrUpdateMessage(message);
      print("Error deleting message: $e");
      // Optionally, show a snackbar to the user
    }
  }
  Future<void> reportUser(String reason) async {
    try {
      await ChatService().reportUser(
        reportedUserId: otherUserUid,
        reason: reason,
      );
    } catch (e) {
      print("Error reporting user: $e");
      rethrow;
    }
  }
}