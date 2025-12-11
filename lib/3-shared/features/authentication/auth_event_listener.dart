// lib/3-shared/features/authentication/auth_event_listener.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // 追加
import 'package:re_conver/3-shared/service/FirebaseApi.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';

void setupAuthListener() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      pr('Auth state changed: User is logged in (${user.uid}). Initializing DBs...');
      
      _setupPresence(user.uid);

      await TemplateRepo().initializeUserDatabases();
      await saveTokenToDatabase();
    } else {
      pr('Auth state changed: User is logged out.');
    }
  });
}

// プレゼンス管理用の関数
void _setupPresence(String uid) {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  final DatabaseReference myStatusRef = database.child('/status/$uid');
  final DatabaseReference connectedRef = database.child('.info/connected');

  connectedRef.onValue.listen((event) {
    final connected = event.snapshot.value as bool? ?? false;
    if (connected) {
      myStatusRef.onDisconnect().update({
        'state': 'offline',
        'last_changed': ServerValue.timestamp,
      }).then((_) {
        myStatusRef.update({
          'state': 'online',
          'last_changed': ServerValue.timestamp,
        });
      });
    }
  });
}