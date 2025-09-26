// lib/2_tenant_feature/4_chat/viewmodel/chat_service.dart
import 'dart:convert'; // Make sure to add this import
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; 

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

    Future<void> updateGeneralNoteAndImages({
    required String threadId,
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
      List<String> newImageUrls = await _uploadImages(threadId, filesToUpload);
      finalImageUrls.addAll(newImageUrls);
    }

    // Update the document with the note and the complete list of image URLs
    await _firestore.collection('chats').doc(threadId).update({
      'generalNote': note,
      'generalImageUrls': finalImageUrls,
    });
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