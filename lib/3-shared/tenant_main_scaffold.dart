import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/3-shared/common_feature/chat/view/providerIndividualChat.dart';
import 'package:re_conver/3-shared/core/model/PostModel.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/view/comment_bottomsheet.dart';
import 'package:re_conver/3-shared/features/authentication/auth_service.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import 'common_feature/chat/view/chatThreadScreen.dart';
import 'features/2_tenant_feature/1_discover/view/discover_screen.dart';
import 'features/2_tenant_feature/3_profile/view/profile_screen.dart';
import 'features/notifications/view/notification_screen.dart';

// ★★★ 追加: プロフィール関連のインポート ★★★
import 'features/2_tenant_feature/3_profile/services/user_service.dart';
import 'features/2_tenant_feature/3_profile/models/profile_model.dart';
import 'features/2_tenant_feature/3_profile/view/edit_profile_screen.dart';

class TenantMainScaffold extends StatefulWidget {
  const TenantMainScaffold({super.key});

  @override
  State<TenantMainScaffold> createState() => _TenantMainScaffoldState();
}

class _TenantMainScaffoldState extends State<TenantMainScaffold> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && !kIsWeb) {
        checkAndRequestNotificationPermission(context);
      }
    });
    _checkPendingAction();
    _scheduleProfileCheck();
    
  }

  void _checkPendingAction() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pendingAction != null && mounted) {
        final action = pendingAction!;
        pendingAction = null; // 実行前にクリア（二重実行防止）
        pr('action type is ${action.type}');
        switch (action.type) {
          
          // ケース1: チャット遷移
          case PendingActionType.chatWithAgent:
            final post = action.payload['post'] as PostModel;
            _navigateToChat(post);
            break;

          // ケース2: コメント投稿（例）
          case PendingActionType.postComment:
            final postId = action.payload['postId'];
            final text = action.payload['text'];
            // ここでコメント投稿APIを呼ぶ、またはコメント画面を開くなど
            _handlePostComment(postId, text);
            break;
          case PendingActionType.chatWithTenant:
            // TODO: Handle this case. tenants cannot chat with tenants
            throw UnimplementedError();
          
        }
      }
    });
  }

  // チャット遷移ロジック（切り出し）
  void _navigateToChat(PostModel post) {
    List<String> uids = [userData.userId, post.userId];
    uids.sort();
    final chatThreadId = uids.join('_');

    final propertyTemplate = PropertyTemplate(
      postId: post.id,
      name: post.condominiumName,
      rent: post.rent,
      location: post.location,
      description: post.description,
      roomType: post.roomType,
      gender: post.gender,
      photoUrls: post.imageUrls,
      nationality: 'Any',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IndividualChatScreenWithProvider(
          chatThreadId: chatThreadId,
          otherUserUid: post.userId,
          otherUserName: post.username,
          otherUserPhotoUrl: post.userProfileImageUrl,
          initialPropertyTemplate: propertyTemplate,
        ),
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome back! Opening chat...')),
    );
  }

  // コメント処理ロジック（例）
  void _handlePostComment(String postId, String text) {
    // 例: コメントボトムシートを自動で開く
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(postId: postId),
    );
    // 必要であれば「ログインしたのでコメントしてください」等のメッセージを表示
  }


  // ★★★ 追加: プロフィールチェックのスケジューリング ★★★
  Future<void> _scheduleProfileCheck() async {
    // 起動またはログイン後、10秒待機
    await Future.delayed(const Duration(seconds: 10));
    
    // ウィジェットが破棄されていたら何もしない
    if (!mounted) return;

    try {
      final userService = UserService();
      // プロフィールを取得
      final userProfile = await userService.getUserProfile();

      // プロフィールが未完成かチェック (hobbyは除く)
      if (_isProfileIncomplete(userProfile)) {
        if (!mounted) return;
        _showCompleteProfileDialog(userProfile);
      }
    } catch (e) {
      print('Error checking profile completion: $e');
    }
  }

  // ★★★ 追加: プロフィールが未完成かどうかを判定するロジック ★★★
  bool _isProfileIncomplete(UserProfile profile) {
    // hobbyの欄を除く、主要なフィールドが初期値または空であるかを確認
    // ProfileModelのデフォルト値を基準に判定
    return profile.displayName == 'New User' ||
        profile.occupation == 'Not specified' ||
        profile.location == 'Not specified' ||
        profile.nationality == 'Not specified' ||
        profile.gender == 'Not specified' ||
        profile.selfIntroduction.isEmpty;
  }

  void _showCompleteProfileDialog(UserProfile userProfile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.account_circle, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Complete Your Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completing your profile brings great benefits!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildBenefitRow(Icons.person_search, 'Agents with matching properties can find and reach out to you.'),
            const SizedBox(height: 12),
            _buildBenefitRow(Icons.chat, 'Smoother transition to chat.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 編集画面へ遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    userProfile: userProfile,
                    isNewUser: false,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Edit Profile Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }

  static const List<Widget> _pages = <Widget>[
    ChatThreadsScreen(),
    DiscoverScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pr('Tenant main scaffold build was called');
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            activeIcon: Icon(Icons.travel_explore_sharp),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}