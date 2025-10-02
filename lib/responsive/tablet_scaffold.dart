import 'package:flutter/material.dart';
import 'package:re_conver/1_agent_feature/2_profile/view/DashBoard.dart';
import 'package:re_conver/2_tenant_feature/2_discover/view/discover_screen.dart';
import 'package:re_conver/2_tenant_feature/3_profile/view/profile_screen.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/chat_thread.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/chatThreadScreen.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/providerIndividualChat.dart';
import 'package:re_conver/authentication/userdata.dart';

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
                    chatThreadId: _selectedThread!.id,
                    otherUserUid: _getOtherParticipantId(_selectedThread!, userData.userId),
                    otherUserName: _selectedThread!.hisName ?? 'Chat User',
                    otherUserPhotoUrl: _selectedThread!.hisPhotoUrl,
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat, size: 100, color: Colors.grey),
                        SizedBox(height: 20),
                        Text('Select a chat to start messaging', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      const DiscoverScreen(),
      isAgent ? MyProfilePage() : const ProfileScreen(),
    ];

    return Scaffold(
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
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('Chat'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.travel_explore),
                selectedIcon: Icon(Icons.travel_explore_sharp),
                label: Text('Discover'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}