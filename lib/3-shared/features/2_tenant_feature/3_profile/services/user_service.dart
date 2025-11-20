// lib/services/user_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Firebase Storage instance

  Future<Map<String, double>?> _getLatLng(String address) async {
    if (address.isEmpty || address == 'Not specified') return null;
    try {
      const apiKey = String.fromEnvironment('GEO_CODE_API_KEY'); // .envから取得
      if (apiKey.isEmpty) return null;

      final encodedAddress = Uri.encodeComponent(address);
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final loc = data['results'][0]['geometry']['location'];
          return {
            'lat': (loc['lat'] as num).toDouble(),
            'lng': (loc['lng'] as num).toDouble(),
          };
        }
      }
    } catch (e) {
      print('Geocoding failed: $e');
    }
    return null;
  }

  // ★ 更新: プロフィール保存時に座標変換を行う
  Future<void> updateUserProfileWithGeo(UserProfile userProfile) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    // 1. 座標リストを作成
    List<Map<String, double>> geolocList = [];

    // 2. 勤務地 (Location) を座標変換
    final workCoords = await _getLatLng(userProfile.location);
    if (workCoords != null) {
      geolocList.add(workCoords);
    }

    // 3. 希望エリア (Preferred Areas) をすべて座標変換
    for (String area in userProfile.preferredAreas) {
      final areaCoords = await _getLatLng(area);
      if (areaCoords != null) {
        geolocList.add(areaCoords);
      }
    }

    // 4. UserProfileデータを更新 (モデルをコピーして更新するイメージ)
    // ここではtoJson()する直前のMapを作って更新します
    final dataToSave = userProfile.toJson();
    dataToSave['_geoloc'] = geolocList; // 計算した座標リストで上書き

    await _firestore
        .collection('users_prof')
        .doc(user.uid)
        .update(dataToSave);
  }

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