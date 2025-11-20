// lib/main.dart
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/viewmodel/deeplink_viewmodel.dart';
import 'package:re_conver/3-shared/features/3_guest_feature/guest_landing_scaffold.dart';
import 'package:re_conver/3-shared/features/authentication/auth_event_listener.dart';
import 'package:template_hive/template_hive.dart';
import '3-shared/features/authentication/role_selection_screen.dart';
import '3-shared/features/notifications/viewmodel/notification_viewmodel.dart';
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

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    pr('Got a message whilst in the foreground!');
    if (message.data['type'] == 'block_update') {
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
        ChangeNotifierProvider(
          create: (_) {
            pr('Creating UnreadMessagesViewModel in MultiProvider');
            return UnreadMessagesViewModel();
          },
        ),
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

    final currentUserId = userData.userId;
    if (currentUserId.isEmpty) {
      pr('Background handler: Could not get current user ID. Aborting.');
      return;
    }

    if (data['action'] == 'blocked_by') {
      final String blockerUid = data['blockerUid'];

      if (blockerUid != currentUserId) {
        pr('Received silent notification: BLOCKED by $blockerUid');
        await chatRepo.addToBlockedUsers(blockerUid);
      } else {
        pr('Ignoring own "blocked_by" notification.');
      }
    } else if (data['action'] == 'unblocked_by') {
      final String unblockerUid = data['unblockerUid'];

      if (unblockerUid != currentUserId) {
        pr('Received silent notification: UNBLOCKED by $unblockerUid');
        await chatRepo.removeFromBlockedUsers(unblockerUid);
      } else {
        pr('Ignoring own "unblocked_by" notification.');
      }
    }
  }
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
      initialRoute: '/',

      // 2. ルート定義を追加
      routes: {'/': (context) => const AuthWrapper()},

      // 3. シェア用URLをキャッチして詳細画面を開くロジック
      onGenerateRoute: (settings) {
        // settings.name には "/listing/123" が入ってきます
        final uri = Uri.parse(settings.name ?? '');

        if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'listing') {
          final postId = uri.pathSegments[1];
          // ここで詳細画面へ遷移
          return MaterialPageRoute(
            builder: (context) => DeepLinkPostView(postId: postId),
          );
        }
        return null;
      },
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
          userData.setUser(user);
          return FutureBuilder<String?>(
            future: _getRoleFromPrefs(user), // ★ 5. user オブジェクトを渡す
            builder: (context, prefsSnapshot) {
              return DelayedFrameBuilder(
                builder: (context) {
                  // このロジックは次のフレームで実行される
                  if (prefsSnapshot.hasData && prefsSnapshot.data != null) {
                    final role = prefsSnapshot.data!;
                    pr('main.dart role is ${role}');
                    userData.setRole(
                      role == 'agent' ? Roles.agent : Roles.tenant,
                    );
                    context.read<UnreadMessagesViewModel>().restartListener();
                    return const ResponsiveLayout();
                  } else {
                    pr('user id is : ${user.uid}');
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users_prof')
                          .doc(user.uid)
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
                              userDocSnapshot.data!.data()
                                  as Map<String, dynamic>;
                          if (data.containsKey('role')) {
                            final role = data['role'] as String;
                            _saveRoleToPrefs(role);
                            userData.setRole(
                              role == 'agent' ? Roles.agent : Roles.tenant,
                            );
                            context
                                .read<UnreadMessagesViewModel>()
                                .restartListener();
                            return const ResponsiveLayout();
                          }
                        }
                        pr(
                          'main.dart// Navigate to the role selection because userdocnapshot : ${userDocSnapshot.hasData} userdocdata existance : ${userDocSnapshot.data!.exists}',
                        );
                        pr('the uid is ${user.uid}');
                        return const RoleSelectionScreen();
                      },
                    );
                  }
                },
              );
            },
          );
        }
        userData.clearUser();

        return DelayedFrameBuilder(
          builder: (context) {
            // GuestLandingScaffold のビルドを1フレーム遅らせる
            // これにより、Algolia (DiscoverScreen内) の初期化が
            // 安定した window オブジェクトに対して行われる
            return const GuestLandingScaffold();
          },
        );
      },
    );
  }
}

// lib/main.dart の一番下に追加

/// 1フレーム待機してから子ウィジェットをビルドするヘルパー
class DelayedFrameBuilder extends StatefulWidget {
  final WidgetBuilder builder;
  const DelayedFrameBuilder({Key? key, required this.builder})
    : super(key: key);

  @override
  State<DelayedFrameBuilder> createState() => _DelayedFrameBuilderState();
}

class _DelayedFrameBuilderState extends State<DelayedFrameBuilder> {
  bool _showChild = false;

  @override
  void initState() {
    super.initState();
    // 現在のフレームが終了した直後に、setStateを呼び出して子ウィジェットを表示する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _showChild = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1フレーム待機する間は、ローディングインジケーターを表示する
    return _showChild
        ? widget.builder(context)
        : const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
