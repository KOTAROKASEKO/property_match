// lib/3-shared/core/responsive/tablet_scaffold.dart

import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:flutter/material.dart';
import 'package:shared_data/shared_data.dart';
import '../../features/1_agent_feature/1_profile/view/agent_profile_view.dart';
import '../../common_feature/chat/view/chatThreadScreen.dart';
import '../../common_feature/chat/view/providerIndividualChat.dart';
import '../../features/2_tenant_feature/1_discover/view/discover_screen.dart';
import '../../features/2_tenant_feature/3_profile/view/profile_screen.dart';
import '../../features/1_agent_feature/2_tenant_list/view/tenant_list_view.dart'; // ★ TenantListView をインポート

class TabletScaffold extends StatefulWidget {
  const TabletScaffold({super.key});

  @override
  State<TabletScaffold> createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<TabletScaffold> {
  int _selectedIndex = 0;
  ChatThread? _selectedThread;

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

  @override
  Widget build(BuildContext context) {
    final isAgent = userData.role == Roles.agent;

    // ★★★ 変更点: isAgent に応じて2番目のページとラベルを切り替える ★★★
    final List<Widget> pages = [
      Row(
        children: [
          SizedBox(
            width: 350,
            child: ChatThreadsScreen(onThreadSelected: _onThreadSelected),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _selectedThread != null
                ? IndividualChatScreenWithProvider(
                    key: ValueKey(_selectedThread!.id), // ★ Keyを追加
                    chatThreadId: _selectedThread!.id,
                    otherUserUid:
                        _getOtherParticipantId(_selectedThread!, userData.userId),
                    otherUserName: _selectedThread!.hisName ?? 'Chat User',
                    otherUserPhotoUrl: _selectedThread!.hisPhotoUrl,
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat, size: 100, color: Colors.grey),
                        SizedBox(height: 20),
                        Text('Select a chat to start messaging',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      // ★ エージェントなら TenantListView、テナントなら DiscoverScreen を表示
      isAgent ? const TenantListView() : const DiscoverScreen(),
      // プロフィール画面は既存のロジックのまま
      isAgent ? MyProfilePage() : const ProfileScreen(),
    ];

    final List<NavigationRailDestination> destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.chat_bubble_outline),
        selectedIcon: Icon(Icons.chat_bubble),
        label: Text('Chat'),
      ),
      // ★ エージェントなら Tenants、テナントなら Discover のラベルとアイコンを表示
      NavigationRailDestination(
        icon: Icon(isAgent ? Icons.people_outline : Icons.travel_explore),
        selectedIcon: Icon(isAgent ? Icons.people : Icons.travel_explore_sharp),
        label: Text(isAgent ? 'Tenants' : 'Discover'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: Text('Profile'),
      ),
    ];
    // ★★★ 変更ここまで ★★★

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                // チャット以外を選択したら、選択中のスレッドを解除する
                if (index != 0) {
                  _selectedThread = null;
                }
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: destinations, // ★ 更新された destinations を使用
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            // ★ Key を追加してページの切り替えを正しく処理
            child: IndexedStack(
              key: ValueKey(_selectedIndex),
              index: _selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}