// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_data/shared_data.dart';
import 'package:shared_data/src/database_path.dart';
import '3-shared/common_feature/chat/viewmodel/unread_messages_viewmodel.dart';
import '3-shared/features/1_agent_feature/1_profile/repo/profile_repository.dart';
import '3-shared/features/1_agent_feature/1_profile/view/agent_post_detail_screen.dart';
import '3-shared/features/1_agent_feature/1_profile/viewmodel/agent_profile_viewmodel.dart';
import '3-shared/features/1_agent_feature/2_tenant_list/viewodel/tenant_list_viewmodel.dart';
import 'package:template_hive/template_hive.dart';
import '3-shared/features/authentication/login_placeholder.dart';
import '3-shared/features/authentication/role_selection_screen.dart';
import '3-shared/features/notifications/viewmodel/notification_viewmodel.dart';
import '3-shared/firebase_options.dart';
import '3-shared/core/responsive/responsive_layout.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '3-shared/features/1_agent_feature/chat_template/viewmodel/agent_template_viewmodel.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");
  await _setupInteractedMessage();
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
          ChangeNotifierProvider(create: (_) => UnreadMessagesViewModel()),
          ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ],
        child: const SafeArea(
          child: MyApp(),
          ),
      ),
  );
}
Future<void> _setupInteractedMessage() async {
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }

  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

void _handleMessage(RemoteMessage message) {
  final postId = message.data['postId'];
  if (message.data['type'] == 'comment' && postId != null) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => AgentPostDetailScreen(postId: postId),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Property_match',
      theme: ThemeData(
        fontFamily: 'fancy',
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    
  }

  
  Future<String?> _getRoleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    print('Getting role : role is ${role}');
    return role;
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
                  future: FirebaseFirestore.instance.collection('users_prof').doc(userData.userId).get(),
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
                      
                      print('main.dart// Navigate to the role selection because userdocnapshot : ${userDocSnapshot.hasData} userdocdata existance : ${userDocSnapshot.data!.exists}');
                      print('the uid is ${userData.userId}');
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