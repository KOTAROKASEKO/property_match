// lib/services/user_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Firebase Storage instance

  // Get the current user's profile
  Future<UserProfile> getUserProfile() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("No user logged in");
    }

    final DocumentSnapshot doc =
        await _firestore.collection('users_prof').doc(user.uid).get();

    if (doc.exists) {
      // If the user profile exists, create a UserProfile object from the data
      return UserProfile.fromFirestore(doc);
    } else {
      // If it's a new user, create a default profile in Firestore
      final newUserProfile = UserProfile(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName ?? 'New User', // Use Firebase Auth display name if available
      );
      await _firestore.collection('users_prof').doc(user.uid).set(newUserProfile.toJson());
      return newUserProfile;
    }
  }

  // Update the user's profile
  Future<void> updateUserProfile(UserProfile userProfile) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("No user logged in");
    }

    await _firestore
        .collection('users_prof')
        .doc(user.uid)
        .update(userProfile.toJson());
  }

  // Renamed method to upload profile image
Future<String> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$userId.jpg'); // Path in Storage
      UploadTask uploadTask;

      // Conditional Upload Logic
      if (kIsWeb) {
        // For Web: Read bytes and use putData
        final Uint8List data = await imageFile.readAsBytes();
        uploadTask = ref.putData(data, SettableMetadata(contentType: imageFile.mimeType ?? 'image/jpeg'));
      } else {
        // For Mobile: Use putFile with dart:io File
        uploadTask = ref.putFile(File(imageFile.path));
      }

      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading profile image: $e"); // Log the specific error
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }
  
}