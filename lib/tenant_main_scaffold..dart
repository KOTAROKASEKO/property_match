import 'package:flutter/material.dart';
import 'package:re_conver/2_tenant_feature/2_discover/view/discover_screen.dart';
import 'package:re_conver/2_tenant_feature/3_profile/view/profile_screen.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/chatThreadScreen.dart';

class TenantMainScaffold extends StatefulWidget {
  const TenantMainScaffold({super.key});

  @override
  State<TenantMainScaffold> createState() => _TenantMainScaffoldState();
}

class _TenantMainScaffoldState extends State<TenantMainScaffold> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // The list of pages is constant and will be kept in memory.
  static const List<Widget> _pages = <Widget>[
    ChatThreadsScreen(),
    DiscoverScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Jump to the page without an animation to mimic standard tab behavior.
    _pageController.jumpToPage(index);
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