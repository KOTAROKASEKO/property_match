import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveTokenToDatabase() async {
    print('saving fcm');
    String token= await FirebaseMessaging.instance.getToken() ?? '';
    print('Saving FCM token: $token');
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('users_token').doc(userId).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
      print("FCM token saved to Firestore.");
    } catch (e) {
      print("Error saving FCM token: $e");
    }
  }