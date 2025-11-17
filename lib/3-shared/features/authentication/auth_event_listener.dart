import 'package:firebase_auth/firebase_auth.dart';
import 'package:re_conver/3-shared/service/FirebaseApi.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';

void setupAuthListener() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      pr(
        'Auth state changed: User is logged in (${user.uid}). Initializing DBs...',
      );
      await TemplateRepo().initializeUserDatabases();
      await saveTokenToDatabase();
    } else {
      pr('Auth state changed: User is logged out.');
    }
  });
}
