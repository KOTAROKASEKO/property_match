// lib/2_tenant_feature/4_chat/viewmodel/chat_service.dart
import 'dart:convert'; // Make sure to add this import
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:re_conver/common_feature/chat/model/chat_thread.dart';
import 'package:re_conver/common_feature/chat/repo/isar_helper.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final IsarService _isarService = IsarService();

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

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Document does not exist!");
      }

      List<dynamic> currentNotes = snapshot.data()?['viewingNotes'] ?? [];
      List<dynamic> currentImageUrls = snapshot.data()?['viewingImageUrls'] ?? [];

      // Ensure arrays are long enough
      while (currentNotes.length <= viewingIndex) {
        currentNotes.add("");
      }
      while (currentImageUrls.length <= viewingIndex) {
        // Use an empty JSON array string for padding
        currentImageUrls.add('[]');
      }
      
      // Update the specific index
      currentNotes[viewingIndex] = note;
      // JSON encode the list of URLs before saving
      currentImageUrls[viewingIndex] = jsonEncode(finalImageUrls);

      // Update the document
      transaction.update(docRef, {
        'viewingNotes': currentNotes,
        'viewingImageUrls': currentImageUrls,
      });
    });
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

  Future<void> updateGeneralNoteAndImages({
    required ChatThread thread,
    required String note,
    required List<dynamic> images,
  }) async {
    List<String> finalImageUrls = [];
    List<File> filesToUpload = [];

    // Separate existing URLs and new files to upload
    for (var image in images) {
      if (image is String) {
        finalImageUrls.add(image);
      } else if (image is File) {
        filesToUpload.add(image);
      }
    }

    // Upload new files and get their URLs
    if (filesToUpload.isNotEmpty) {
      List<String> newImageUrls = await _uploadImages(thread.id, filesToUpload);
      finalImageUrls.addAll(newImageUrls);
    }

    // Update the document with the note and the complete list of image URLs
    await _firestore.collection('chats').doc(thread.id).update({
      'generalNote': note,
      'generalImageUrls': finalImageUrls,
    });
    //update isar
    thread.generalNote = note;
    thread.generalImageUrls = finalImageUrls; 
    
    _isarService.saveChatThread(thread);
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