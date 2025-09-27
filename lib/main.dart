// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/template_model.dart';
import 'package:re_conver/authentication/login_placeholder.dart';
import 'package:re_conver/authentication/role_selection_screen.dart';
import 'package:re_conver/authentication/userdata.dart';
import 'package:re_conver/MainScaffold.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/agent_profile_model.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/timestamp_adopter.dart';
import 'package:re_conver/firebase_options.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await RiveFile.initialize();
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(TimestampAdapter());
  Hive.registerAdapter(TemplateModelAdapter()); // Register the adapter
  await Hive.openBox<UserProfile>('userProfileBox');
  await Hive.openBox<TemplateModel>('templateBox'); // Open the template box

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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String?> _getRoleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<void> _saveRoleToPrefs(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: _getRoleFromPrefs(),
            builder: (context, prefsSnapshot) {
              if (prefsSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (prefsSnapshot.hasData && prefsSnapshot.data != null) {
                final role = prefsSnapshot.data!;
                userData.setRole(role == 'agent' ? Roles.agent : Roles.tenant);
                return const MainScaffold();
              } else {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users_prof').doc(snapshot.data!.uid).get(),
                  builder: (context, userDocSnapshot) {
                    if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(body: Center(child: CircularProgressIndicator()));
                    }

                    if (userDocSnapshot.hasData && userDocSnapshot.data!.exists) {
                      final data = userDocSnapshot.data!.data() as Map<String, dynamic>;
                      if (data.containsKey('role')) {
                        final role = data['role'] as String;
                        _saveRoleToPrefs(role); // Firestoreから取得したロールを保存
                        userData.setRole(role == 'agent' ? Roles.agent : Roles.tenant);
                        return const MainScaffold();
                      }
                    }
                    
                    return const RoleSelectionScreen();
                  },
                );
              }
            },
          );
        }

        return const LoginPlaceholderScreen();
      },
    );
  }
}