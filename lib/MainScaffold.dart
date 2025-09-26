import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:re_conver/1_agent_feature/tenant_list_view.dart';
import 'package:re_conver/2_tenant_feature/2_discover/view/agent_profile_screen.dart';
import 'package:re_conver/2_tenant_feature/3_profile/view/profile_screen.dart';
import 'package:re_conver/authentication/login_placeholder.dart';
import 'package:re_conver/2_tenant_feature/2_discover/view/discover_screen.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/chatThreadScreen.dart';
import 'package:re_conver/authentication/userdata.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  
  // Define widgets and items for both roles
  late final List<Widget> _tenantWidgets;
  late final List<Widget> _agentWidgets;
  late final List<BottomNavigationBarItem> _tenantNavItems;
  late final List<BottomNavigationBarItem> _agentNavItems;

  @override
  void initState() {
    super.initState();
    
    // Define Tenant Widgets
    _tenantWidgets = <Widget>[
      const ChatThreadsScreen(),
      const DiscoverScreen(),
      const ProfileScreen(),
    ];

    // Define Tenant Navigation Bar Items
    _tenantNavItems = const <BottomNavigationBarItem>[
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
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    // Define Agent Widgets
    _agentWidgets = <Widget>[
      const ChatThreadsScreen(),
      TenantListView(), // Your custom agent screen
      const OtherUserProfileScreen(userId: ''),
    ];

    // Define Agent Navigation Bar Items
    _agentNavItems = const <BottomNavigationBarItem>[
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
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine which set of UI elements to use based on the role
    final bool isAgent = userData.role == Roles.agent;
    final List<Widget> currentWidgets = isAgent ? _agentWidgets : _tenantWidgets;
    final List<BottomNavigationBarItem> currentNavItems = isAgent ? _agentNavItems : _tenantNavItems;

    // Use a StreamBuilder to handle the login state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        // If the user is not logged in, show the placeholder
        if (!snapshot.hasData) {
          // You might want a dedicated screen here, but for now, we can show the first tab's placeholder
          return const Scaffold(body: LoginPlaceholderScreen());
        }

        // If the user is logged in, show the scaffold with the correct UI
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: currentWidgets,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: currentNavItems,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}