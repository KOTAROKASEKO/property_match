// lib/3-shared/agent_main_scaffold.dart

import 'dart:async'; // <-- 1. Import this
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/common_feature/chat/view/providerIndividualChat.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/3_profile/models/profile_model.dart';
import 'package:re_conver/3-shared/features/authentication/auth_service.dart';
import 'package:shared_data/shared_data.dart';
import 'features/1_agent_feature/1_profile/view/agent_profile_view.dart';
import 'features/1_agent_feature/2_tenant_list/view/tenant_list_view.dart';
import 'common_feature/chat/view/chatThreadScreen.dart';
import 'common_feature/chat/viewmodel/unread_messages_viewmodel.dart';
import 'features/authentication/login_placeholder.dart';
import 'features/notifications/view/notification_screen.dart'; // Make sure this import exists

class AgentMainScaffold extends StatefulWidget {
  const AgentMainScaffold({super.key});
  @override
  State<AgentMainScaffold> createState() => _AgentMainScaffoldState();
}

class _AgentMainScaffoldState extends State<AgentMainScaffold> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late final List<Widget> _pages;
  
  // <-- 2. Store the subscription
  StreamSubscription<User?>? _authSubscription;


  @override
  void initState() {

    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted && user != null && !kIsWeb) {
        checkAndRequestNotificationPermission(context);
        _checkPendingAction();
      }
    });

    if (userId == null) {
      _pages = [
        const LoginPlaceholderScreen(),
        const LoginPlaceholderScreen(),
        const LoginPlaceholderScreen(),
      ];
    } else {
      _pages = [
        const ChatThreadsScreen(),
        TenantListView(),
        MyProfilePage(),
      ];
    }
  }

  void _checkPendingAction() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('is pending action null ${pendingAction== null}');
      if (pendingAction != null && mounted) {
        final action = pendingAction!;
        pendingAction = null; // 二重実行防止のためにクリア

        // アクションの種類が「テナントとのチャット」の場合
        if (action.type == PendingActionType.chatWithTenant) {
          final tenant = action.payload['tenant'] as UserProfile;
          _navigateToChat(tenant);
        }
      }
    });
  }

  // ★★★ 追加: チャット画面への遷移ロジック ★★★
  void _navigateToChat(UserProfile tenant) {
    // チャットIDの生成
    List<String> uids = [userData.userId, tenant.uid];
    uids.sort();
    final chatThreadId = uids.join('_');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IndividualChatScreenWithProvider(
          chatThreadId: chatThreadId,
          otherUserUid: tenant.uid,
          otherUserName: tenant.displayName,
          otherUserPhotoUrl: tenant.profileImageUrl,
          // Agentからの開始なのでPropertyTemplateは空でOK、
          // もし特定の物件について話したい場合はここでセットすることも可能
        ),
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Continuing chat with ${tenant.displayName}...')),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _authSubscription?.cancel(); // <-- 5. Cancel the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Consumer<UnreadMessagesViewModel>(
              builder: (context, viewModel, child) {
                final unreadCount = viewModel.totalUnreadCount;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.chat_bubble_outline),
                    if (unreadCount > 0)
                      Positioned(
                        right: -8,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            activeIcon: const Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Tenants',
          ),
          const BottomNavigationBarItem(
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