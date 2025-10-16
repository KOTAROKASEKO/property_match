// lib/agent_main_scaffold.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 追加
import 'package:re_conver/features/1_agent_feature/1_profile/view/agent_profile_view.dart';
import 'package:re_conver/features/1_agent_feature/2_tenant_list/view/tenant_list_view.dart';
import 'package:re_conver/common_feature/chat/view/chatThreadScreen.dart';
import 'package:re_conver/common_feature/chat/viewmodel/unread_messages_viewmodel.dart'; // 追加
import 'package:re_conver/features/authentication/login_placeholder.dart';
import 'package:re_conver/features/notifications/view/notification_screen.dart';

class AgentMainScaffold extends StatefulWidget {
  const AgentMainScaffold({super.key});
  @override
  State<AgentMainScaffold> createState() => _AgentMainScaffoldState();
}

class _AgentMainScaffoldState extends State<AgentMainScaffold> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        checkAndRequestNotificationPermission(context);
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