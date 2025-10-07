// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/common_feature/chat/model/blocked_model.dart';
import 'package:re_conver/common_feature/chat/repo/TemplateRepo.dart';
import 'package:re_conver/features/1_agent_feature/1_profile/repo/profile_repository.dart';
import 'package:re_conver/features/1_agent_feature/1_profile/viewmodel/agent_profile_viewmodel.dart';
import 'package:re_conver/features/1_agent_feature/2_tenant_list/viewodel/tenant_list_viewmodel.dart';
import 'package:re_conver/features/1_agent_feature/chat_template/model/property_template.dart';
import 'package:re_conver/common_feature/chat/model/template_model.dart';
import 'package:re_conver/features/authentication/login_placeholder.dart';
import 'package:re_conver/features/authentication/role_selection_screen.dart';
import 'package:re_conver/common_feature/chat/model/timestamp_adopter.dart';
import 'package:re_conver/features/authentication/userdata.dart';
import 'package:re_conver/firebase_options.dart';
import 'package:re_conver/core/responsive/responsive_layout.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:re_conver/features/1_agent_feature/chat_template/viewmodel/agent_template_viewmodel.dart';


//box names
String agentTemplateMessageBoxName = 'agentMessageTemplates';
String tenanTemplateMessageBoxName = 'tenantMessageTemplates';
String propertyTemplateBox = 'propertyTemplateBox';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await RiveFile.initialize();
  await Hive.initFlutter();

  Hive.registerAdapter(TimestampAdapter());
  Hive.registerAdapter(TemplateModelAdapter());
  Hive.registerAdapter(PropertyTemplateAdapter());
  
  await Hive.openBox<TemplateModel>(tenanTemplateMessageBoxName);
  await Hive.openBox<TemplateModel>(agentTemplateMessageBoxName);
  await Hive.openBox<PropertyTemplate>(propertyTemplateBox);

  userData.setUser(FirebaseAuth.instance.currentUser);

  runApp(
    MultiProvider(
        providers: [
        ChangeNotifierProvider(create: (_) => TenantListViewModel()),
          ChangeNotifierProvider(create: (_) => ProfileViewModel(FirestoreProfileRepository())),
          ChangeNotifierProvider(create: (_) => AgentTemplateViewModel()),
        ],
        child: const SafeArea(
          child: MyApp(),
          ),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Property_match',
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