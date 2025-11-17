// lib/3-shared/core/responsive/tablet_scaffold.dart

import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:flutter/material.dart';
import 'package:shared_data/shared_data.dart';
import '../../features/1_agent_feature/1_profile/view/agent_profile_view.dart';
import '../../common_feature/chat/view/chatThreadScreen.dart';
import '../../common_feature/chat/view/providerIndividualChat.dart';
import '../../features/2_tenant_feature/1_discover/view/discover_screen.dart';
import '../../features/2_tenant_feature/3_profile/view/profile_screen.dart';
import '../../features/1_agent_feature/2_tenant_list/view/tenant_list_view.dart'; 

class TabletScaffold extends StatefulWidget {
  const TabletScaffold({super.key});

  @override
  State<TabletScaffold> createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<TabletScaffold> {
  int _selectedIndex = 0;
  ChatThread? _selectedThread;

  // ★★★ 1. ページリストの宣言を削除 ★★★
  // late final List<Widget> _agentPages;
  // late final List<Widget> _tenantPages;
  late final bool _isAgent;

  // ★★★ 2. 状態を保持するウィジェットをメンバ変数として宣言 ★★★
  late final ChatThreadsScreen _chatThreadsScreen;
  late final TenantListView _tenantListView;
  late final MyProfilePage _myProfilePage;
  late final DiscoverScreen _discoverScreen;
  late final ProfileScreen _profileScreen;


  void _onThreadSelected(ChatThread thread) {
    setState(() {
      _selectedThread = thread;
    });
  }

  String _getOtherParticipantId(ChatThread thread, String currentUserId) {
    return thread.whoReceived != currentUserId
        ? thread.whoReceived
        : thread.whoSent;
  }

  // ★★★ 3. initState でウィジェットのインスタンスを一度だけ作成 ★★★
  @override
  void initState() {
    super.initState();
    _isAgent = userData.role == Roles.agent;

    // --- 状態を保持したいウィジェットをここで初期化 ---
    _chatThreadsScreen = ChatThreadsScreen(onThreadSelected: _onThreadSelected);
    _tenantListView = TenantListView();
    _myProfilePage = MyProfilePage();
    _discoverScreen = DiscoverScreen();
    _profileScreen = ProfileScreen();

    // --- ページリストの作成は build メソッドに移動 ---
  }

  // ( _buildChatDetailView は変更なし)
  Widget _buildChatDetailView() {
    if (_selectedThread != null) {
      return IndividualChatScreenWithProvider(
        key: ValueKey(_selectedThread!.id),
        chatThreadId: _selectedThread!.id,
        otherUserUid: _getOtherParticipantId(_selectedThread!, userData.userId),
        otherUserName: _selectedThread!.hisName ?? 'Chat User',
        otherUserPhotoUrl: _selectedThread!.hisPhotoUrl,
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text('Select a chat to start messaging',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    pr('build method in tablet scaffold was called');
    
    // ★★★ 4. ページリストを build メソッド内で動的に構築 ★★★
    final List<Widget> pages;
    if (_isAgent) {
      pages = [
        Row( // Index 0: Chat
          children: [
            SizedBox(
              width: 350,
              child: _chatThreadsScreen, // ★ 1. 保存したインスタンスを再利用
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _buildChatDetailView(), // ★ 2. ここで毎回呼び出し、最新の _selectedThread を反映
            ),
          ],
        ),
        _tenantListView,  // ★ 1. 保存したインスタンスを再利用
        _myProfilePage, // ★ 1. 保存したインスタンスを再利用
      ];
    } else {
      pages = [
        Row( // Index 0: Chat
          children: [
            SizedBox(
              width: 350,
              child: _chatThreadsScreen, // ★ 1. 保存したインスタンスを再利用
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _buildChatDetailView(), // ★ 2. ここで毎回呼び出し、最新の _selectedThread を反映
            ),
          ],
        ),
        _discoverScreen, // ★ 1. 保存したインスタンスを再利用
        _profileScreen,  // ★ 1. 保存したインスタンスを再利用
      ];
    }

    final List<NavigationRailDestination> destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.chat_bubble_outline),
        selectedIcon: Icon(Icons.chat_bubble),
        label: Text('Chat'),
      ),
      NavigationRailDestination(
        icon: Icon(_isAgent ? Icons.people_outline : Icons.travel_explore),
        selectedIcon: Icon(_isAgent ? Icons.people : Icons.travel_explore_sharp),
        label: Text(_isAgent ? 'Tenants' : 'Discover'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: Text('Profile'),
      ),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                if (index != 0) {
                  _selectedThread = null;
                }
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: pages, // ★ 5. 動的に構築されたリストを使用
            ),
          ),
        ],
      ),
    );
  }
}