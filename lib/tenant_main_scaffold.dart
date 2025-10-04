import 'package:flutter/material.dart';
import 'package:re_conver/2_tenant_feature/3_profile/view/profile_screen.dart';
import 'package:re_conver/common_feature/chat/view/chatThreadScreen.dart';
import 'package:re_conver/features/2_tenant_feature/1_discover/view/discover_screen.dart';

class TenantMainScaffold extends StatefulWidget {
  const TenantMainScaffold({super.key});

  @override
  State<TenantMainScaffold> createState() => _TenantMainScaffoldState();
}

class _TenantMainScaffoldState extends State<TenantMainScaffold> {
  int _selectedIndex = 0;

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