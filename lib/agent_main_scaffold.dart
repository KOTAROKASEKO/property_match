import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/features/1_agent_feature/1_profile/view/agent_profile_view.dart';
import 'package:re_conver/features/1_agent_feature/2_tenant_list/view/tenant_list_view.dart';
import 'package:re_conver/common_feature/chat/view/chatThreadScreen.dart';
import 'package:re_conver/features/authentication/login_placeholder.dart';

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
    
    // This check ensures we have a user ID for the profile screen.
    // The AuthWrapper in main.dart should prevent userId from being null here.
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

// agent_main_scaffold.dart

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // PageControllerが利用可能かを確認し、スムーズなアニメーションでページを切り替える
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Tenants',
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