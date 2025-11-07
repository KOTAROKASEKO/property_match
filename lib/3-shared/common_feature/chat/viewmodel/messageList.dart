// lib/common_feature/chat/viewmodel/messageList.dart

import 'dart:async';
import 'dart:convert';

import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import 'chat_service.dart'; // Keep for Firestore operations like reportUser

class MessageListProvider extends ChangeNotifier {
  final String chatThreadId;
  final String otherUserUid;
  late final ChatRepository _chatRepository; // Use the abstract type ✨

  MessageListProvider({
    required this.chatThreadId,
    required this.otherUserUid,
    required ChatRepository chatRepository, // 引数で受け取る
  }) : _chatRepository = chatRepository {
    // 受け取ったものを使うだけ
    _initializeAndLoadData();
  }

  // --- Firestore/Storage instances (remain the same) ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  StreamSubscription? _firebaseMessagesSubscription;
  StreamSubscription? _blockSubscription;

  // --- State variables (remain mostly the same) ---
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  MessageModel? _editingMessage;
  bool _isLoadingMore = false;
  bool _canLoadMore = true;
  List<dynamic> _displayItems = [];
  MessageModel? _replyingToMessage;
  DocumentSnapshot? _lastVisible; // Firestore pagination cursor\
  bool _isBlocked = false;

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
  bool get isBlocked => _isBlocked;

  static const int _messagesPerPage = 20;

  // --- Helper methods for state management (remain the same) ---
  void setLoading(bool loading) {
    if (_isLoading == loading) return; // Avoid unnecessary notifications
    _isLoading = loading;
    notifyListeners();
  }

  void setLoadingMore(bool loading) {
    if (_isLoadingMore == loading) return;
    _isLoadingMore = loading;
    notifyListeners();
  }

  void setCanLoadMore(bool canLoad) {
    _canLoadMore = canLoad;
  }

  void setSending(bool sending) {
    if (_isSending == sending) return;
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

  void didScrollToBottom() {
    _shouldScrollToBottom = false;
  }

  // --- Initialization ---
  Future<void> _initializeAndLoadData() async {
    try {
      if (kIsWeb) {
        // A案 (Web): 起動時にFirestoreから1回だけ取得
        await _checkBlockStatusFromFirestore();
      } 
        // C案 (Mobile): ローカルDBの変更をリアルタイムで監視
        if(!kIsWeb){
          _listenToBlockStatus();
        }
      
      
      await loadInitialMessages();
      listenToFirebaseMessages();
      markMessagesAsRead();
    } catch (e) {
      pr("Error initializing or loading initial data: $e");
      // Handle initialization error appropriately
    }
  }

  Future<void> _checkBlockStatusFromFirestore() async {
    pr('[MessageListProvider] Running A-Plan (Web): Checking Firestore block list...');
    bool currentlyBlocked = false;
    try {
      // 1. 自分が相手をブロックしているか？
      final myBlockListDoc = await _firestore
          .collection('blockedList')
          .doc(userData.userId)
          .get();

      if (myBlockListDoc.exists && myBlockListDoc.data() != null) {
        final List<dynamic> myBlockedUsers =
            myBlockListDoc.data()!['blockedUsers'] ?? [];
        if (myBlockedUsers.contains(otherUserUid)) {
          pr('I am blokcing him');
          currentlyBlocked = true;
          await _chatRepository.addToBlockedUsers(otherUserUid);
        }else{
          pr('I am not blocking him');
        }
      }

      // 2. 相手が自分をブロックしているか？
      if (!currentlyBlocked) {
        final otherBlockListDoc = await _firestore
            .collection('blockedList')
            .doc(otherUserUid) // ★ 相手のUID
            .get();

        if (otherBlockListDoc.exists && otherBlockListDoc.data() != null) {
          final List<dynamic> otherBlockedUsers =
              otherBlockListDoc.data()!['blockedUsers'] ?? [];
          if (otherBlockedUsers.contains(userData.userId)) {
            pr('other user is blocking me');
            currentlyBlocked = true;
            await _chatRepository.addToBlockedUsers(otherUserUid);
          }
        }
      }
    } catch (e) {
      pr("Error checking block status from Firestore: $e");
    }

    // 状態をセット（notifyListeners() は _initializeAndLoadData が終わるまで不要）
    _isBlocked = currentlyBlocked;
    pr('[MessageListProvider] A-Plan check complete: isBlocked = $_isBlocked');
  }

  void _listenToBlockStatus() {
    _blockSubscription?.cancel();
    // _chatRepository (Isar/Drift) が提供する Stream を監視する
    // main.dart の FCM ハンドラが書き込むのと同じ場所
    _blockSubscription = _chatRepository.watchBlockedUsers().listen((blockedUserIds) {
      // ★ 相手(otherUserUid)ではなく、ブロックしてきた側(blockerUid)を
      //    監視する必要があるのでは？ -> いいえ、相手がリストにいるかでOK
      //    FCMハンドラは「ブロックしてきた人」をリストに追加するので
      //    otherUserUid がリストに含まれているかを見ればOK
      
      // ... と思ったが、FCMハンドラは「自分がブロックされた」相手(blockerUid)を
      // リストに追加している。
      // chat_service の blockUser は「自分がブロックした」相手(blockedUserId)を
      // リストに追加している。
      // つまり、このリストは「自分がブロックした人」と「自分をブロックした人」の
      // 両方が入るリストになっている。
      // よって、このロジックで正しい。
      pr('current user id : ${userData.userId}');
      pr('blockedUserIds from Local DB: $blockedUserIds');

      final bool currentlyBlocked = blockedUserIds.contains(otherUserUid);
      
      if (_isBlocked != currentlyBlocked) {
        _isBlocked = currentlyBlocked;
        pr('[MessageListProvider] Block status changed (from Local DB): $_isBlocked');
        notifyListeners();
      }
    });
  }

  Future<void> loadInitialMessages() async {
    if (_isLoading) return;
    setLoading(true);

    try {
      pr('[MessageListProvider] Loading initial messages from local DB...');
      // 1. Load from local DB (Isar or Drift via Repository) ✨
      _messages = await _chatRepository.getMessagesForChatRoom(
        chatThreadId,
        limit: _messagesPerPage,
      );
      _buildDisplayListWithDates();
      setLoading(false); // Show cached data immediately
      pr(
        '[MessageListProvider] Loaded ${_messages.length} messages from local DB.',
      );

      pr('[MessageListProvider] Fetching initial messages from Firestore...');
      // 2. Fetch from Firestore to sync and get the pagination cursor
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatThreadId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(_messagesPerPage)
          .get();

      pr(
        '[MessageListProvider] Fetched ${snapshot.docs.length} messages from Firestore.',
      );

      if (snapshot.docs.isNotEmpty) {
        _lastVisible = snapshot.docs.last; // Set pagination cursor
        final firestoreMessages = snapshot.docs.map((doc) {
          final data = doc.data();
          final message = _mapFirestoreDocToMessageModel(
            doc.id,
            data,
          ); // Use helper
          // Save/Update in local DB via Repository ✨
          _chatRepository.createOrUpdateMessage(message);
          return message;
        }).toList();

        // Update the UI list with Firestore data
        _messages = firestoreMessages;
        _buildDisplayListWithDates();
        setCanLoadMore(firestoreMessages.length == _messagesPerPage);
        notifyListeners(); // Update UI with fresh data
      } else {
        _canLoadMore = false;
        // If local had messages but Firestore doesn't, clear local (or handle sync strategy)
        if (_messages.isNotEmpty) {
          pr(
            '[MessageListProvider] Firestore is empty, clearing local messages.',
          );
          // Decide if you want to clear local cache if Firestore is empty
          // _messages = [];
          // _buildDisplayListWithDates();
          // notifyListeners();
          // Optionally clear local DB too: await _chatRepository.deleteChatThreadMessages(chatThreadId);
        }
      }
    } catch (e) {
      pr("Error loading initial messages: $e");
      setLoading(false); // Ensure loading indicator stops on error
    }
  }

  Future<void> loadMoreMessages() async {
    if (_isLoadingMore || !_canLoadMore || _lastVisible == null) return;
    setLoadingMore(true);
    pr('[MessageListProvider] Loading more messages from Firestore...');

    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatThreadId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastVisible!) // Use the cursor
          .limit(_messagesPerPage)
          .get();

      pr(
        '[MessageListProvider] Fetched ${snapshot.docs.length} more messages from Firestore.',
      );

      if (snapshot.docs.isNotEmpty) {
        _lastVisible = snapshot.docs.last; // Update cursor
        final olderMessages = snapshot.docs.map((doc) {
          final data = doc.data();
          final message = _mapFirestoreDocToMessageModel(doc.id, data);
          // Save/Update in local DB via Repository ✨
          _chatRepository.createOrUpdateMessage(message);
          return message;
        }).toList();

        // Add older messages without duplicates
        final existingMessageIds = _messages.map((m) => m.messageId).toSet();
        final uniqueOlderMessages = olderMessages
            .where((m) => !existingMessageIds.contains(m.messageId))
            .toList();
        _messages.addAll(
          uniqueOlderMessages,
        ); // Add to the end (since list is reversed in UI)

        _buildDisplayListWithDates(); // Rebuild display list
        setCanLoadMore(olderMessages.length == _messagesPerPage);
        notifyListeners(); // Update UI
      } else {
        setCanLoadMore(false); // No more messages to load
      }
    } catch (e) {
      pr("Error loading more messages from Firestore: $e");
    } finally {
      setLoadingMore(false);
    }
  }

  // --- Firestore Listening ---
  void listenToFirebaseMessages() {
    _firebaseMessagesSubscription?.cancel();
    pr('[MessageListProvider] Starting Firestore listener...');

    // Determine the starting point for the listener
    Timestamp startAfterTimestamp = _messages.isNotEmpty
        ? Timestamp.fromDate(
            _messages.first.timestamp,
          ) // Get timestamp of the *latest* message in the current list
        : Timestamp.fromMillisecondsSinceEpoch(
            0,
          ); // Or start from beginning if list is empty

    _firebaseMessagesSubscription = _firestore
        .collection('chats')
        .doc(chatThreadId)
        .collection('messages')
        .orderBy('timestamp', descending: false) // Listen in ascending order
        .where(
          'timestamp',
          isGreaterThan: startAfterTimestamp,
        ) // Only get newer messages
        .snapshots()
        .listen(
          (snapshot) async {
            if (!snapshot.docChanges.isNotEmpty) return;
            pr(
              '[MessageListProvider] Received ${snapshot.docChanges.length} changes from Firestore listener.',
            );

            bool requiresUIRefresh = false;
            bool newIncomingMessage = false;

            for (var change in snapshot.docChanges) {
              final doc = change.doc;
              final data = doc.data();
              if (data == null) continue;

              final message = _mapFirestoreDocToMessageModel(doc.id, data);

              if (change.type == DocumentChangeType.added) {
                pr('[MessageListProvider] Added message: ${message.messageId}');
                // Save/Update in local DB via Repository ✨
                await _chatRepository.createOrUpdateMessage(message);

                // Add to UI list if not already present (handles potential duplicates)
                final index = _messages.indexWhere(
                  (m) => m.messageId == message.messageId,
                );
                if (index == -1) {
                  _addOrUpdateMessageInUI(message);
                  if (!message.isOutgoing) {
                    newIncomingMessage = true;
                  }
                  requiresUIRefresh = true;
                }
              } else if (change.type == DocumentChangeType.modified) {
                pr(
                  '[MessageListProvider] Modified message: ${message.messageId}',
                );
                await _chatRepository.createOrUpdateMessage(message);
                _messages.indexWhere((m) => m.messageId == message.messageId);
                _addOrUpdateMessageInUI(message);
              } else if (change.type == DocumentChangeType.removed) {
                pr(
                  '[MessageListProvider] Removed message: ${message.messageId}',
                );
                // TODO: Handle removal in local DB via Repository if needed (e.g., hard delete)
                // await _chatRepository.deleteMessagePermanently(message.messageId); // Example

                // Remove from UI list
                _messages.removeWhere((m) => m.messageId == message.messageId);
                requiresUIRefresh = true;
              }
            }

            if (requiresUIRefresh) {
              _buildDisplayListWithDates(); // Rebuild display list after updates
              if (newIncomingMessage) {
                _shouldScrollToBottom =
                    true; // Flag to scroll down on new incoming
                markMessagesAsRead(); // Mark as read when new message arrives
              }
              notifyListeners();
            }
          },
          onError: (error) {
            pr("Error listening to Firebase messages: $error");
          },
        );
  }

  // --- Sending / Editing / Deleting ---
  Future<void> sendMessage({
    String? text,
    XFile? imageFile,
    XFile? audioFile,
    PropertyTemplate? propertyTemplate,
  }) async {
    // Basic validation
    if ((text == null || text.trim().isEmpty) &&
        imageFile == null &&
        audioFile == null &&
        propertyTemplate == null) {
      pr('[MessageListProvider] Send cancelled: No content.');
      return;
    }
    if (isSending) {
      pr('[MessageListProvider] Send cancelled: Already sending.');
      return;
    }

    setSending(true);
    final replyingTo = _replyingToMessage; // Capture reply context
    if (replyingTo != null) setReplyingTo(null); // Clear reply state in UI

    final tempMessageId = _firestore
        .collection('_')
        .doc()
        .id; // Generate temporary ID
    final now = DateTime.now();
    String messageType = 'text';
    String? localPath;
    String? messageContent = text?.trim();
    String lastMessageText = text?.trim() ?? ''; // For chat thread preview

    // Determine message type and content
    if (imageFile != null) {
      messageType = 'image';
      localPath = imageFile.path;
      lastMessageText = '[Image]';
      messageContent = null; // Text content is not used for images
    } else if (audioFile != null) {
      messageType = 'audio';
      localPath = audioFile.path;
      lastMessageText = '[Voice Message]';
      messageContent = null; // Text content is not used for audio
    } else if (propertyTemplate != null) {
      messageType = 'property_template';
      final templateMap = {
        'postId': propertyTemplate.postId, // Include postId if needed
        'name': propertyTemplate.name,
        'rent': propertyTemplate.rent,
        'location': propertyTemplate.location,
        'description': propertyTemplate.description,
        'photoUrls': propertyTemplate.photoUrls,
        'gender': propertyTemplate.gender,
        'roomType': propertyTemplate.roomType,
        'nationality': propertyTemplate.nationality,
      };
      messageContent = jsonEncode(
        templateMap,
      ); // Encode template as JSON string
      lastMessageText = 'Property: ${propertyTemplate.name}';
    }

    // Create optimistic message for UI and local DB
    MessageModel optimisticMessage = MessageModel()
      ..messageId =
          tempMessageId // Use temp ID
      ..chatRoomId = chatThreadId
      ..whoSent = userData.userId
      ..whoReceived = otherUserUid
      ..isOutgoing = true
      ..messageText =
          messageContent // Can be null for image/audio
      ..messageType = messageType
      ..status =
          'sending' // Initial status
      ..timestamp = now
      ..localPath =
          localPath // Store local path for image/audio
      ..repliedToMessageId = replyingTo?.messageId
      ..repliedToMessageText = _getRepliedTextPreview(replyingTo)
      ..repliedToWhoSent = replyingTo?.whoSent;

    // Add to local DB and UI optimistically ✨
    await _chatRepository.createOrUpdateMessage(optimisticMessage);
    _addOrUpdateMessageInUI(optimisticMessage);
    _shouldScrollToBottom = true;
    notifyListeners();

    try {
      String? remoteUrl; // URL after upload

      // Upload file if necessary
      if (imageFile != null) {
        remoteUrl = await _uploadFileToStorage(
          imageFile, // ★ XFile をそのまま渡す
          'chat_images/$chatThreadId/$tempMessageId', // More specific path
        );
        pr('[MessageListProvider] Image uploaded: $remoteUrl');
      } else if (audioFile != null) {
        // ★★★ FIX: audioFile もアップロードするロジックに変更 ★★★
        remoteUrl = await _uploadFileToStorage(
          audioFile, // ★ XFile をそのまま渡す
          'chat_audio/$chatThreadId/$tempMessageId', // ★ audio 用のパスに変更
        );
        pr('[MessageListProvider] Audio uploaded: $remoteUrl');
      }

      // Prepare data for Firestore
      Map<String, dynamic> firebaseMessageData = {
        'whoSentId': userData.userId,
        'whoReceivedId': otherUserUid,
        'messageType': messageType,
        'timestamp': Timestamp.fromDate(now), // Use Firestore Timestamp
        'status': 'sent', // Mark as sent in Firestore
        'text': messageContent, // Store JSON string or text
        'remoteUrl': remoteUrl, // Store uploaded URL
        'repliedToMessageId': replyingTo?.messageId,
        'repliedToMessageText': _getRepliedTextPreview(replyingTo),
        'repliedToWhoSent': replyingTo?.whoSent,
        'isRead': false, // Initially unread by receiver
        'editedAt': null, // Not edited yet
        'operation': 'normal', // Default operation
      };

      // Send to Firestore
      await _firestore
          .collection('chats')
          .doc(chatThreadId)
          .collection('messages')
          .doc(tempMessageId) // Use the same ID
          .set(firebaseMessageData);

      pr('[MessageListProvider] Message sent to Firestore: $tempMessageId');

      // Update local message status to 'sent' ✨
      optimisticMessage.status = 'sent';
      optimisticMessage.remoteUrl = remoteUrl; // Store remote URL locally too
      await _chatRepository.createOrUpdateMessage(optimisticMessage);
      _addOrUpdateMessageInUI(optimisticMessage); // Update UI status

      // Update chat thread last message info (Firestore)
      await _firestore.collection('chats').doc(chatThreadId).set(
        {
          'lastMessage': lastMessageText,
          'timeStamp': Timestamp.fromDate(now),
          'whoSent': userData.userId,
          'whoReceived': otherUserUid,
          'messageType': messageType,
          'lastMessageId': tempMessageId,
          // Increment unread count for the *other* user
          'unreadCount_${otherUserUid}': FieldValue.increment(1),
          // Ensure participant IDs exist for querying threads
          'participants': [userData.userId, otherUserUid],
        },
        SetOptions(merge: true),
      ); // Use merge to avoid overwriting other fields

      pr('[MessageListProvider] Chat thread updated.');
    } catch (e) {
      pr("Error sending message: $e");
      // Update local message status to 'failed' ✨
      optimisticMessage.status = 'failed';
      await _chatRepository.createOrUpdateMessage(optimisticMessage);
      _addOrUpdateMessageInUI(optimisticMessage); // Update UI status
      // Optionally show error to user via Snackbar
    } finally {
      setSending(false); // Stop sending indicator
    }
  }

  Future<void> saveEditedMessage(String editedText) async {
    if (_editingMessage == null || editedText.trim().isEmpty) {
      setEditingMessage(null); // Cancel editing if no message or empty text
      return;
    }

    final messageToUpdate = _editingMessage!;
    final originalText =
        messageToUpdate.messageText; // Keep original for rollback
    final now = DateTime.now();

    // Optimistic UI update
    messageToUpdate.messageText = editedText.trim();
    messageToUpdate.editedAt = now;
    messageToUpdate.operation = 'edited';
    _addOrUpdateMessageInUI(messageToUpdate);
    setEditingMessage(null); // Clear editing state in UI

    try {
      // Update local DB ✨
      await _chatRepository.createOrUpdateMessage(messageToUpdate);

      // Update Firestore
      await _firestore
          .collection('chats')
          .doc(messageToUpdate.chatRoomId)
          .collection('messages')
          .doc(messageToUpdate.messageId)
          .update({
            'text': editedText.trim(),
            'editedAt': Timestamp.fromDate(now),
            'operation': 'edited',
          });
      pr(
        '[MessageListProvider] Edited message saved: ${messageToUpdate.messageId}',
      );
    } catch (e) {
      pr("Error saving edited message: $e");
      // Rollback UI changes on failure
      messageToUpdate.messageText = originalText;
      messageToUpdate.editedAt = null; // Revert timestamp
      messageToUpdate.operation = 'normal'; // Revert operation
      _addOrUpdateMessageInUI(messageToUpdate);
      // Optionally notify user of failure
    }
  }

  void cancelEditing() {
    setEditingMessage(null);
  }

  Future<void> deleteMessageForEveryone(MessageModel message) async {
    final originalText = message.messageText;
    final originalStatus = message.status;
    final originalOperation = message.operation;

    pr(
      '[MessageListProvider] Attempting to delete message: ${message.messageId}',
    );

    // Optimistically update UI and local DB
    message.messageText = 'This message was deleted';
    message.status = 'deleted_for_everyone';
    message.operation = 'deleted'; // Use a specific operation state
    message.remoteUrl = null; // Clear potential URLs
    message.localPath = null; // Clear local paths

    _addOrUpdateMessageInUI(message); // Update UI immediately
    try {
      await _chatRepository.createOrUpdateMessage(message); // Update local DB ✨
      pr('[MessageListProvider] Message updated locally for deletion.');
    } catch (e) {
      pr("Error updating local message for deletion: $e");
      // If local update fails, maybe revert UI? Depends on desired behavior.
    }

    try {
      final chatThreadRef = _firestore.collection('chats').doc(chatThreadId);
      final messageRef = chatThreadRef
          .collection('messages')
          .doc(message.messageId);

      await _firestore.runTransaction((transaction) async {
        final chatThreadDoc = await transaction.get(chatThreadRef);
        final messageDoc = await transaction.get(messageRef);

        if (!messageDoc.exists) {
          pr(
            '[MessageListProvider] Message ${message.messageId} already deleted or does not exist in Firestore.',
          );
          return; // Message already gone
        }

        // Update the message document in Firestore
        transaction.update(messageRef, {
          'text': 'This message was deleted', // Keep consistent text
          'status': 'deleted_for_everyone',
          'operation': 'deleted',
          'remoteUrl': null, // Clear remote URL in Firestore too
          // Keep timestamp, whoSent, etc. for context
        });

        // If the deleted message was the *last* message in the thread...
        if (chatThreadDoc.exists &&
            chatThreadDoc.data()?['lastMessageId'] == message.messageId) {
          pr(
            '[MessageListProvider] Deleted message was the last message. Finding previous message...',
          );
          // Query for the new last message (the one before the deleted one)
          final previousMessagesQuery = chatThreadRef
              .collection('messages')
              .where(
                FieldPath.documentId,
                isNotEqualTo: message.messageId,
              ) // Exclude the deleted one
              .orderBy('timestamp', descending: true)
              .limit(1); // Get the most recent remaining message

          final previousMessagesSnapshot = await previousMessagesQuery
              .get(); // Get outside transaction

          if (previousMessagesSnapshot.docs.isNotEmpty) {
            // Update thread with the previous message's info
            final newLastMessageDoc = previousMessagesSnapshot.docs.first;
            final newLastMessageData = newLastMessageDoc.data();
            final newLastMessageText = _getLastMessageTextPreview(
              newLastMessageData,
            );
            pr(
              '[MessageListProvider] Updating thread with previous message: ${newLastMessageDoc.id}',
            );
            transaction.update(chatThreadRef, {
              'lastMessage': newLastMessageText,
              'timeStamp': newLastMessageData['timestamp'],
              'whoSent': newLastMessageData['whoSentId'],
              'whoReceived': newLastMessageData['whoReceivedId'],
              'messageType': newLastMessageData['messageType'],
              'lastMessageId': newLastMessageDoc.id,
            });
          } else {
            pr(
              '[MessageListProvider] No previous messages found. Clearing thread last message info.',
            );
            // No other messages left, clear the last message fields
            transaction.update(chatThreadRef, {
              'lastMessage': null, //'No messages yet.',
              'lastMessageId': null,
              'messageType': null, // Or 'text'
              'timeStamp':
                  FieldValue.serverTimestamp(), // Update timestamp maybe?
            });
          }
        }
      });
      pr(
        '[MessageListProvider] Firestore transaction successful for deletion.',
      );
    } catch (e) {
      pr("Error deleting message in Firestore transaction: $e");
      // Rollback UI and local DB on Firestore failure
      message.messageText = originalText;
      message.status = originalStatus;
      message.operation = originalOperation;
      // Re-fetch remoteUrl/localPath if needed, or assume they are unchanged if rollback is simple
      _addOrUpdateMessageInUI(message);
      try {
        await _chatRepository.createOrUpdateMessage(
          message,
        ); // Revert local DB ✨
        pr('[MessageListProvider] Rollback successful.');
      } catch (rollbackError) {
        pr("Error rolling back local message state: $rollbackError");
      }
      // Optionally, show a snackbar to the user
    }
  }

  // --- Helper Methods ---

  // Maps Firestore document data to a MessageModel instance
  MessageModel _mapFirestoreDocToMessageModel(
    String docId,
    Map<String, dynamic> data,
  ) {
    final message = MessageModel()
      ..messageId = docId
      ..chatRoomId =
          chatThreadId // Assuming this is correct context
      ..whoSent = data['whoSentId'] as String? ?? ''
      ..whoReceived = data['whoReceivedId'] as String? ?? ''
      ..isOutgoing = (data['whoSentId'] as String?) == userData.userId
      ..messageText = data['text'] as String?
      ..messageType = data['messageType'] as String? ?? 'text'
      ..operation = data['operation'] as String? ?? 'normal'
      ..status = data['status'] as String? ?? 'sent'
      ..timestamp = (data['timestamp'] as Timestamp? ?? Timestamp.now())
          .toDate()
      ..editedAt = (data['editedAt'] as Timestamp?)?.toDate()
      ..remoteUrl = data['remoteUrl'] as String?
      ..repliedToMessageId = data['repliedToMessageId'] as String?
      ..repliedToMessageText = data['repliedToMessageText'] as String?
      ..repliedToWhoSent = data['repliedToWhoSent'] as String?
      ..isRead = data['isRead'] as bool? ?? false; // Handle potential null
    return message;
  }

  Future<String> _uploadFileToStorage(XFile file, String path) async {
    try {
      final ref = _storage.ref().child(path);

      final Uint8List data = await file.readAsBytes();
      final uploadTask = ref.putData(data);

      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      pr("Error uploading file ($path): $e");
      throw Exception("File upload failed: ${e.toString()}");
    }
  }

  String? _getRepliedTextPreview(MessageModel? message) {
    if (message == null) return null;
    switch (message.messageType) {
      case 'text':
      case 'property_template': // Maybe show property name?
        return message.messageText;
      case 'image':
        return '[Image]';
      case 'audio':
        return '[Voice Message]';
      default:
        return '[Unsupported message]';
    }
  }

  // Generates preview text for the last message in the chat thread
  String _getLastMessageTextPreview(Map<String, dynamic>? data) {
    if (data == null) return '';
    final type = data['messageType'] as String?;
    switch (type) {
      case 'text':
        return data['text'] as String? ?? '';
      case 'property_template':
        try {
          // Attempt to decode JSON and get name, fallback if fails
          final content = data['text'] as String?;
          if (content != null) {
            final Map<String, dynamic> templateData = jsonDecode(content);
            return 'Property: ${templateData['name'] ?? '...'}';
          }
        } catch (_) {}
        return '[Property]';
      case 'image':
        return '[Image]';
      case 'audio':
        return '[Voice Message]';
      default:
        return data['text'] as String? ?? '[Unsupported message]';
    }
  }

  // Updates or adds a message in the UI list (_messages)
  // Ensures the list remains sorted by timestamp after modification.
  void _addOrUpdateMessageInUI(MessageModel message) {
    final index = _messages.indexWhere((m) => m.messageId == message.messageId);
    if (index != -1) {
      _messages[index] = message; // Update existing
    } else {
      _messages.add(message); // Add new
    }
    // Sort messages by timestamp descending after adding/updating
    // This ensures _messages[0] is always the latest for the listener query
    _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _buildDisplayListWithDates(); // Rebuild the list used by ListView.builder
    // No need to call notifyListeners() here, as it's called by the calling methods
  }

  // Marks messages as read in Firestore
  Future<void> markMessagesAsRead() async {
    // Find unread incoming messages *currently in the UI list*
    final unreadMessagesInUI = _messages
        .where((m) => !m.isOutgoing && !m.isRead)
        .toList();
    if (unreadMessagesInUI.isEmpty) return;

    pr(
      '[MessageListProvider] Marking ${unreadMessagesInUI.length} messages as read...',
    );

    // Update Firestore via batch write
    final batch = _firestore.batch();
    for (var message in unreadMessagesInUI) {
      final messageRef = _firestore
          .collection('chats')
          .doc(chatThreadId)
          .collection('messages')
          .doc(message.messageId);
      batch.update(messageRef, {'isRead': true});
    }
    // Reset the current user's unread count on the thread document
    final threadRef = _firestore.collection('chats').doc(chatThreadId);
    batch.set(threadRef, {
      'unreadCount_${userData.userId}': 0,
    }, SetOptions(merge: true)); // Use set with merge

    try {
      await batch.commit();
      pr('[MessageListProvider] Firestore updated for read status.');

      // Update local state (UI and DB)
      for (var message in unreadMessagesInUI) {
        message.isRead = true;
        // Update local DB via Repository ✨
        await _chatRepository.createOrUpdateMessage(message);
      }
      notifyListeners(); // Update UI to show read status (e.g., double ticks)
    } catch (e) {
      pr("Error marking messages as read: $e");
    }
  }

  // Clears the message list (e.g., when opening a chat)
  void clearMessages() {
    _messages.clear();
    _displayItems.clear();
    _editingMessage = null;
    _replyingToMessage = null;
    _lastVisible = null; // Reset pagination cursor
    _canLoadMore = true; // Reset load more flag
    pr('[MessageListProvider] Message list cleared.');
    // Don't notify listeners here if it's part of initial loading
  }

  void _buildDisplayListWithDates() {
    if (_messages.isEmpty) {
      _displayItems = [];
      return;
    }

    List<dynamic> newDisplayList = [];
    DateTime? lastDate;

    for (int i = _messages.length - 1; i >= 0; i--) {
      final message = _messages[i];
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

  Future<void> reportUser(String reason) async {
    try {
      await ChatService().reportUser(
        reportedUserId: otherUserUid,
        reason: reason,
      );
      pr('[MessageListProvider] User reported: $otherUserUid, Reason: $reason');
    } catch (e) {
      pr("Error reporting user: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    pr('[MessageListProvider] Disposing...');
    _firebaseMessagesSubscription?.cancel(); // Cancel Firestore listener
    _blockSubscription?.cancel();
    super.dispose();
  }
}
