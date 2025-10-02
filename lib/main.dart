// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/1_agent_feature/2_profile/repo/profile_repository.dart';
import 'package:re_conver/1_agent_feature/2_profile/viewmodel/profile_viewmodel.dart';
import 'package:re_conver/1_agent_feature/3_tenant_list/viewodel/tenant_list_viewmodel.dart';
import 'package:re_conver/1_agent_feature/chat_template/property_template.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/template_model.dart';
import 'package:re_conver/2_tenant_feature/4_chat/viewmodel/messageTemplate_viewmodel.dart';
import 'package:re_conver/authentication/login_placeholder.dart';
import 'package:re_conver/authentication/role_selection_screen.dart';
import 'package:re_conver/authentication/userdata.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/timestamp_adopter.dart';
import 'package:re_conver/firebase_options.dart';
import 'package:re_conver/responsive/responsive_layout.dart';
import 'package:re_conver/service/local_notification.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:re_conver/1_agent_feature/chat_template/viewmodel/agent_template_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
  await RiveFile.initialize();
  await Hive.initFlutter();
  Hive.registerAdapter(TimestampAdapter());
  Hive.registerAdapter(TemplateModelAdapter());
  Hive.registerAdapter(PropertyTemplateAdapter());
  userData.setUser(FirebaseAuth.instance.currentUser);
  await Hive.openBox<TemplateModel>('tenantMessageTemplates');
  await Hive.openBox<TemplateModel>('agentMessageTemplates');
  await Hive.openBox<PropertyTemplate>('propertyTemplateBox'); 


  runApp(
    MultiProvider(
      providers: [
       ChangeNotifierProvider(create: (_) => TenantListViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(FirestoreProfileRepository())),
      ],
      child: const MyApp(),
    ),
  );
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
                return const ResponsiveLayout();
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
                        _saveRoleToPrefs(role);
                        userData.setRole(role == 'agent' ? Roles.agent : Roles.tenant);
                        return const ResponsiveLayout();
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