import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../authentication/userdata.dart';
class NotificationViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _unreadCountSubscription;
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  NotificationViewModel() {
    listenToUnreadCount();
  }

  void listenToUnreadCount() {
    _unreadCountSubscription?.cancel();
    if (userData.userId.isEmpty) return;

    _unreadCountSubscription = _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userData.userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      _unreadCount = snapshot.docs.length;
      notifyListeners();
    });
  }

  Stream<QuerySnapshot> notificationsStream() {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userData.userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markAllAsRead() async {
    if (userData.userId.isEmpty) return;
    
    final querySnapshot = await _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userData.userId)
        .where('isRead', isEqualTo: false)
        .get();
        
    final batch = _firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  void dispose() {
    _unreadCountSubscription?.cancel();
    super.dispose();
  }
}