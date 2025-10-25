// lib/2_tenant_feature/4_chat/viewmodel/chat_service.dart
import 'dart:convert'; // Make sure to add this import
import 'dart:io';

import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_data/shared_data.dart';
import '../../repository_provider.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ChatRepository _isarService = getChatRepository();

  Future<void> updateViewingDetails({
  required String threadId,
  required String note,
  required List<dynamic> images,
  required int viewingIndex,
}) async {
  List<String> finalImageUrls = [];
  List<File> filesToUpload = [];

  for (var image in images) {
    if (image is String) {
      finalImageUrls.add(image);
    } else if (image is File) {
      filesToUpload.add(image);
    }
  }

  if (filesToUpload.isNotEmpty) {
    List<String> newImageUrls = await _uploadImages(threadId, filesToUpload);
    finalImageUrls.addAll(newImageUrls);
  }

  final docRef = _firestore.collection('chats').doc(threadId);

  // ★★★ 役割に応じたフィールド名を取得 ★★★
  String viewingNotePath = userData.role == Roles.agent ? 'agentViewingNote' : 'tenantViewingNote';
  String photoImagePath = userData.role == Roles.agent ? 'agentphotoPath' : 'tenantPhotoPath';

  await _firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(docRef);
    if (!snapshot.exists) {
      throw Exception("Document does not exist!");
    }

    // ★★★ 役割に応じたフィールドからデータを読み込む ★★★
    List<dynamic> currentNotes = snapshot.data()?[viewingNotePath] ?? [];
    List<dynamic> currentImageUrls = snapshot.data()?[photoImagePath] ?? [];
    
    while (currentNotes.length <= viewingIndex) {
      currentNotes.add("");
    }
    while (currentImageUrls.length <= viewingIndex) {
      currentImageUrls.add('[]');
    }
    
    currentNotes[viewingIndex] = note;
    currentImageUrls[viewingIndex] = jsonEncode(finalImageUrls);

    // ★★★ 役割に応じたフィールドにデータを書き込む ★★★
    transaction.update(docRef, {
      viewingNotePath: currentNotes,
      photoImagePath: currentImageUrls,
    });
  });
}



  Future<void> blockUser(String blockedUserId) async {

    try{
      await _isarService.addToBlockedUsers(blockedUserId);
    }catch(e){
      print('Error blocking a user :${e}');
    }
  }

    Future<void> unblockUser(String blockedUserId) async {
    
      final docRef = _firestore.collection('blockedList').doc(userData.userId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        return;
      }

      // *** THE FIX IS HERE ***
      // 1. Get the list from Firestore.
      final List<dynamic> currentBlocked = snapshot.data()?['blockedUsers'] ?? [];
      
      // 2. Create a new, explicitly growable list from the original.
      final updatedBlocked = List.from(currentBlocked)
        ..remove(blockedUserId); // Now .remove() will work safely.

      // 3. Update Firestore with the new list.
      transaction.update(docRef, {'blockedUsers': updatedBlocked});
      print('The user was updated on firestore successfully');
    });
  }

  Future<void> updateGeneralNoteAndImages({
    required ChatThread thread,
    required String note,
    required List<dynamic> images,
  }) async {
    List<String> finalImageUrls = [];
    List<File> filesToUpload = [];

    for (var image in images) {
      if (image is String) {
        finalImageUrls.add(image);
      } else if (image is File) {
        filesToUpload.add(image);
      }
    }

    if (filesToUpload.isNotEmpty) {
      List<String> newImageUrls = await _uploadImages(thread.id, filesToUpload);
      finalImageUrls.addAll(newImageUrls);
    }

    // ★★★ 役割に応じたフィールド名を取得 ★★★
    String generalNotePath = userData.role == Roles.agent ? 'agentGeneralNote' : 'tenantGeneralNote';
    String generalphotoImagePath = userData.role == Roles.agent ? 'agentGeneralPhotoPath' : 'tenantGeneralPhotoPath';

    // ★★★ 役割に応じたフィールドにデータを書き込む ★★★
    await _firestore.collection('chats').doc(thread.id).update({
      generalNotePath: note,
      generalphotoImagePath: finalImageUrls,
    });
    
    // isarも更新
    if (userData.role == Roles.agent) {
      thread.generalNote = note;
      thread.generalImageUrls = finalImageUrls;
    } else {
      // Assuming you might add separate fields in Isar model later if needed
      thread.generalNote = note;
      thread.generalImageUrls = finalImageUrls;
    }
    _isarService.saveChatThread(thread);
  }

  Future<void> deleteChat(String threadId) async {
    // 1. Delete from Firestore
    // First, get all messages in the subcollection
    final messagesRef = _firestore.collection('chats').doc(threadId).collection('messages');
    final messagesSnapshot = await messagesRef.get();

    // Use a batch to delete all messages efficiently
    final WriteBatch batch = _firestore.batch();
    for (var doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // After deleting the subcollection, delete the main chat document
    await _firestore.collection('chats').doc(threadId).delete();
    
    // 2. Delete from the local Isar database
    await _isarService.deleteChatThreadAndMessages(threadId);
  }

  Future<List<String>> _uploadImages(String threadId, List<File> files) async {
    List<Future<String>> uploadFutures = files.map((file) async {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      Reference ref = _storage.ref().child('viewing_images').child(threadId).child(fileName);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    }).toList();

    return await Future.wait(uploadFutures);
  }

  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    await _firestore.collection('user_reports').add({
      'reportedUserId': reportedUserId,
      'reportedBy': currentUser.uid,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}