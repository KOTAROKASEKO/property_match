import 'package:flutter/material.dart';
import 'package:re_conver/3-shared/features/1_agent_feature/2_tenant_list/view/tenant_list_view.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/view/discover_screen.dart';
import 'package:re_conver/3-shared/features/authentication/login_placeholder.dart';
import 'package:re_conver/3-shared/language_selector.dart';

class GuestLandingScaffold extends StatefulWidget {
  const GuestLandingScaffold({super.key});

  @override
  State<GuestLandingScaffold> createState() => _GuestLandingScaffoldState();
}

class _GuestLandingScaffoldState extends State<GuestLandingScaffold> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DiscoverScreen(),
    TenantListView(),
  ];

  void _navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoginPlaceholderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      // ★修正: TitleをRowにして、テキストと言語セレクターを並べる
      title: const Row(
        mainAxisSize: MainAxisSize.min, // 必要に応じて調整
        children: [
          Text(
            'Bilik Match',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          
        ],
      ),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      actions: [
        
          // ★言語セレクターを追加
          LanguageSelector(
            iconColor: Colors.white70,
            textColor: Colors.white,
          ),
          SizedBox(width: 12), // 少し間隔を空ける
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton.icon(
            onPressed: _navigateToLogin,
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text(
              'Login / Sign Up',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              overlayColor: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );

    // ... (以下変更なし)
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Scaffold(
            appBar: appBar,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.travel_explore_outlined),
                      selectedIcon: Icon(Icons.travel_explore),
                      label: Text('Discover'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Tenants'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: appBar,
            body: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.travel_explore_outlined),
                  activeIcon: Icon(Icons.travel_explore),
                  label: 'Discover',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Tenants',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.deepPurple,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          );
        }
      },
    );
  }
}