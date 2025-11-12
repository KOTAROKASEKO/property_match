// lib/main.dart
import 'package:re_conver/3-shared/features/3_guest_feature/guest_landing_scaffold.dart';
import 'package:template_hive/template_hive.dart';
// ★ 修正: このパスは元々正しかった
// ★ 修正: このパスは元々正しかった
import '3-shared/features/authentication/role_selection_screen.dart';
import '3-shared/features/notifications/viewmodel/notification_viewmodel.dart';
// ★ 修正: このパスは元々正しかった
import '3-shared/firebase_options.dart';
import '3-shared/core/responsive/responsive_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/common_feature/repository_provider.dart';
import 'package:re_conver/3-shared/service/FirebaseApi.dart';
import 'package:shared_data/shared_data.dart';
import '3-shared/common_feature/chat/viewmodel/unread_messages_viewmodel.dart';
import '3-shared/features/1_agent_feature/1_profile/repo/profile_repository.dart';
import '3-shared/features/1_agent_feature/1_profile/view/agent_post_detail_screen.dart';
import '3-shared/features/1_agent_feature/1_profile/viewmodel/agent_profile_viewmodel.dart';
import '3-shared/features/1_agent_feature/2_tenant_list/viewodel/tenant_list_viewmodel.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '3-shared/features/1_agent_feature/chat_template/viewmodel/agent_template_viewmodel.dart';

// ★★★ IMPORT THE NEW GUEST SCAFFOLD ★★★

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ★ アプリがフォアグラウンド（起動中）の時も
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    pr('Got a message whilst in the foreground!');
    if (message.data['type'] == 'block_update') {
      // バックグラウンドハンドラと同じ処理を実行
      _firebaseMessagingBackgroundHandler(message);
    }
  });

  await dotenv.load(fileName: ".env");
  await _setupInteractedMessage();
  await RiveFile.initialize();
  await Hive.initFlutter();

  Hive.registerAdapter(TimestampAdapter());
  Hive.registerAdapter(TemplateModelAdapter());
  Hive.registerAdapter(PropertyTemplateAdapter());

  userData.setUser(FirebaseAuth.instance.currentUser);

  setupAuthListener();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TenantListViewModel()),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(FirestoreProfileRepository()),
        ),
        ChangeNotifierProvider(create: (_) => AgentTemplateViewModel()),
        ChangeNotifierProvider(create: (_) => UnreadMessagesViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ],
      child: const SafeArea(child: MyApp()),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  pr("Handling a background message: ${message.messageId}");

  final Map<String, dynamic> data = message.data;
  if (data['type'] == 'block_update') {
    final chatRepo = getChatRepository();

    // 自分のUIDを (FirebaseAuth.instance からではなく) shared_data から取得
    // 注: バックグラウンド実行のため、userData.userId が初期化されている必要があります。
    // もし初期化されていない場合は、ここで User? user = FirebaseAuth.instance.currentUser; を
    // 使う必要がありますが、グローバルシングルトンが使える前提で進めます。
    final currentUserId = userData.userId;
    if (currentUserId.isEmpty) {
      pr('Background handler: Could not get current user ID. Aborting.');
      return;
    }

    if (data['action'] == 'blocked_by') {
      final String blockerUid = data['blockerUid'];
      
      // ★★★ 修正点 ★★★
      // ブロックしたのが自分自身ではない場合のみ、ローカルDBに追加する
      if (blockerUid != currentUserId) {
        pr('Received silent notification: BLOCKED by $blockerUid');
        await chatRepo.addToBlockedUsers(blockerUid);
      } else {
        pr('Ignoring own "blocked_by" notification.');
      }

    } else if (data['action'] == 'unblocked_by') {
      final String unblockerUid = data['unblockerUid'];

      // ★★★ 修正点 ★★★
      // ブロック解除したのが自分自身ではない場合のみ、ローカルDBから削除する
      if (unblockerUid != currentUserId) {
        pr('Received silent notification: UNBLOCKED by $unblockerUid');
        await chatRepo.removeFromBlockedUsers(unblockerUid);
      } else {
        pr('Ignoring own "unblocked_by" notification.');
      }
    }
  }
}

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

Future<void> _setupInteractedMessage() async {
  RemoteMessage? initialMessage = await FirebaseMessaging.instance
      .getInitialMessage();
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

  // ★ 1. _getRoleFromPrefs が User オブジェクトを引数に取るように変更
  Future<String?> _getRoleFromPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    if (role == null) {
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        
        // ★ 2. userData.userId.isEmpty チェックを削除
        //    代わりに引数の user.uid を使用

        final doc = await firestore
            .collection('users_prof')
            .doc(user.uid) // ★ 3. user.uid を使用
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['role'] != null) {
            _saveRoleToPrefs(data['role']);
            role = data['role'];
            return role;
          }
          return null;
        }
      } catch (e) {
        pr('error during getting role from firestore : ${e}');
      }
    }
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!; // ★ 4. user オブジェクトを取得
          userData.setUser(user); // userData のセットは引き続き行う
          
          return FutureBuilder<String?>(
            future: _getRoleFromPrefs(user), // ★ 5. user オブジェクトを渡す
            builder: (context, prefsSnapshot) {
              if (prefsSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (prefsSnapshot.data == null) {
                pr('Role not in prefs, checking Firestore or navigating to RoleSelection...');
              }
              
              if (prefsSnapshot.hasData && prefsSnapshot.data != null) {
                final role = prefsSnapshot.data!;
                pr('main.dart role is ${role}');
                userData.setRole(role == 'agent' ? Roles.agent : Roles.tenant);
                return const ResponsiveLayout();
              } else {
                pr('user id is : ${user.uid}'); // ★ 6. ログも user.uid を使用
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users_prof')
                      .doc(user.uid) // ★ 7. user.uid を使用
                      .get(),
                  builder: (context, userDocSnapshot) {
                    if (userDocSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (userDocSnapshot.hasData &&
                        userDocSnapshot.data!.exists) {
                      final data =
                          userDocSnapshot.data!.data() as Map<String, dynamic>;
                      if (data.containsKey('role')) {
                        final role = data['role'] as String;
                        _saveRoleToPrefs(role);
                        userData.setRole(
                          role == 'agent' ? Roles.agent : Roles.tenant,
                        );
                        return const ResponsiveLayout();
                      }
                    }

                    pr(
                      'main.dart// Navigate to the role selection because userdocnapshot : ${userDocSnapshot.hasData} userdocdata existance : ${userDocSnapshot.data!.exists}',
                    );
                    pr('the uid is ${user.uid}'); // ★ 8. user.uid を使用
                    return const RoleSelectionScreen();
                  },
                );
              }
            },
          );
        }
        
        // ★★★ START OF MODIFICATION ★★★
        // If snapshot.hasData is false, user is logged out.
        userData.clearUser(); // Clear any stale user data
        // Show the new guest landing page instead of the old logic
        return const GuestLandingScaffold();
        // ★★★ END OF MODIFICATION ★★★
        
      },
    );
  }
}