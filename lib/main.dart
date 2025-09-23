// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:re_conver/authentication/userdata.dart';
import 'package:re_conver/MainScaffold.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/user_profile_model.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/timestamp_adopter.dart';
import 'package:re_conver/firebase_options.dart';
import 'package:rive/rive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await RiveFile.initialize();
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(TimestampAdapter());
  await Hive.openBox<UserProfile>('userProfileBox');

  userData.setUser(FirebaseAuth.instance.currentUser);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Re:Conver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SafeArea(
        child:MainScaffold()
        ),
    );
  }
}