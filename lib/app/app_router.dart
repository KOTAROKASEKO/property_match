import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
// 各画面をimport
import 'package:re_conver/3-shared/core/responsive/responsive_layout.dart';
import 'package:re_conver/3-shared/features/authentication/login_placeholder.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/viewmodel/deeplink_viewmodel.dart'; // DeepLinkPostView

// 認証状態を監視するためのNotifier (Provider等を使っても良いですが簡易的に)
class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get user => _auth.currentUser;

  AuthNotifier() {
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }
}

final authNotifier = AuthNotifier();

final GoRouter appRouter = GoRouter(
  refreshListenable: authNotifier, // 認証状態が変わったらリダイレクトを再評価
  initialLocation: '/',
  routes: [
    // 1. ホーム (ResponsiveLayout)
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const ResponsiveLayout(),
    ),
    
    // 2. ログイン画面
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPlaceholderScreen(),
    ),

    // 3. Deep Link (シェアされた物件詳細)
    // main.dartの onGenerateRoute のロジックをここに移動
    GoRoute(
      path: '/listing/:id',
      name: 'listing_detail',
      builder: (context, state) {
        final postId = state.pathParameters['id']!;
        return DeepLinkPostView(postId: postId);
      },
    ),
    
    // その他、role_selectionなどは必要に応じて追加
  ],

  // 4. リダイレクトロジック (AuthWrapperの代わり)
  redirect: (context, state) {
    final isLoggedIn = authNotifier.user != null;
    final isLoggingIn = state.matchedLocation == '/login';
    
    // DeepLink等は除外したい場合があるので条件分岐
    // final isListing = state.matchedLocation.startsWith('/listing');

    if (!isLoggedIn && !isLoggingIn) {
      // 未ログインならログイン画面へ (ただしゲスト機能を許可する場合は調整が必要)
      // GuestLandingScaffold のロジックを考慮すると、完全にブロックせず
      // ゲスト画面を '/' に割り当てるなどの調整が必要です。
      return null; 
    }

    if (isLoggedIn && isLoggingIn) {
      // ログイン済みでログイン画面に来たらホームへ
      return '/';
    }

    return null; // そのまま
  },
);