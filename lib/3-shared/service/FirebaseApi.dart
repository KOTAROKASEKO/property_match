import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveTokenToDatabase() async {
    if (kIsWeb) {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Proceed only if permission is granted
    if (settings.authorizationStatus != AuthorizationStatus.authorized && 
        settings.authorizationStatus != AuthorizationStatus.provisional) { // Provisional is acceptable for web
      print('Notification permission not granted. Cannot get FCM token.');
      // Optionally show a message to the user explaining why notifications won't work
      return;
    }
  }
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