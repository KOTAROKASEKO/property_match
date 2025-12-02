// lib/3-shared/core/responsive/tablet_scaffold.dart

import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/3-shared/common_feature/chat/view/chatThreadScreen.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart'; // ★ PropertyTemplate用にインポート
import '../../features/1_agent_feature/1_profile/view/agent_profile_view.dart';
import '../../common_feature/chat/view/providerIndividualChat.dart';
import '../../features/2_tenant_feature/1_discover/view/discover_screen.dart';
import '../../features/2_tenant_feature/3_profile/view/profile_screen.dart';
import '../../features/1_agent_feature/2_tenant_list/view/tenant_list_view.dart'; 

// ★ Pending Action 用のインポートを追加
import '../../features/authentication/auth_service.dart';
import '../../core/model/PostModel.dart';
import '../../features/2_tenant_feature/3_profile/models/profile_model.dart';

class TabletScaffold extends StatefulWidget {
  const TabletScaffold({super.key});

  @override
  State<TabletScaffold> createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<TabletScaffold> {
  int _selectedIndex = 0;
  ChatThread? _selectedThread;
  PropertyTemplate? _pendingPropertyTemplate; // ★ Pending Actionからのテンプレート保持用

  late final bool _isAgent;

  late final ChatThreadsScreen _chatThreadsScreen;
  late final TenantListView _tenantListView;
  late final MyProfilePage _myProfilePage;
  late final DiscoverScreen _discoverScreen;
  late final ProfileScreen _profileScreen;

  void _onThreadSelected(ChatThread thread) {
    setState(() {
      _selectedThread = thread;
      _pendingPropertyTemplate = null; // ★ 手動選択時はテンプレートをクリア
    });
  }

  String _getOtherParticipantId(ChatThread thread, String currentUserId) {
    return thread.whoReceived != currentUserId
        ? thread.whoReceived
        : thread.whoSent;
  }

  @override
  void initState() {
    super.initState();
    _isAgent = userData.role == Roles.agent;

    _chatThreadsScreen = ChatThreadsScreen(onThreadSelected: _onThreadSelected);
    _tenantListView = TenantListView();
    _myProfilePage = MyProfilePage();
    _discoverScreen = DiscoverScreen();
    _profileScreen = ProfileScreen();

    // ★ 起動時（ログイン直後）にPending Actionをチェック
    _checkPendingAction();
  }

  // ★★★ Pending Action 処理ロジック ★★★
  void _checkPendingAction() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pendingAction != null && mounted) {
        final action = pendingAction!;
        bool actionHandled = false;

        // エージェントがテナントへチャットしようとしている場合
        if (_isAgent && action.type == PendingActionType.chatWithTenant) {
          final tenant = action.payload['tenant'] as UserProfile;
          _handleChatWithTenant(tenant);
          actionHandled = true;
        } 
        // テナントがエージェントへチャット（Inquire）しようとしている場合
        else if (!_isAgent && action.type == PendingActionType.chatWithAgent) {
          final post = action.payload['post'] as PostModel;
          _handleChatWithAgent(post);
          actionHandled = true;
        }

        // 処理したらクリア
        if (actionHandled) {
          pr('TabletScaffold: Handled pending action ${action.type}');
          pendingAction = null;
        }
      }
    });
  }

  // エージェント用: テナントとのチャットを開く
 // エージェント用: テナントとのチャットを開く
  void _handleChatWithTenant(UserProfile tenant) {
    final chatThreadId = _generateChatThreadId(userData.userId, tenant.uid);
    
    // ★ 修正: コンストラクタ引数ではなく、カスケード記法でプロパティを設定
    final dummyThread = ChatThread()
      ..id = chatThreadId
      ..whoSent = userData.userId
      ..whoReceived = tenant.uid
      ..lastMessage = ''
      ..timeStamp = DateTime.now()
      ..unreadCountMap = {} // setter経由でjsonに変換されます
      ..viewingTimes = []
      ..viewingNotes = []
      ..viewingImageUrls = []
      ..generalImageUrls = []
      ..hisName = tenant.displayName
      ..hisPhotoUrl = tenant.profileImageUrl;

    setState(() {
      _selectedIndex = 0; // チャットタブへ切り替え
      _selectedThread = dummyThread;
      _pendingPropertyTemplate = null;
    });
    
    _showSnackBar('Continuing chat with ${tenant.displayName}...');
  }

  // テナント用: 物件について問い合わせる
  void _handleChatWithAgent(PostModel post) {
    final chatThreadId = _generateChatThreadId(userData.userId, post.userId);

    final dummyThread = ChatThread()
      ..id = chatThreadId
      ..whoSent = userData.userId
      ..whoReceived = post.userId
      ..lastMessage = ''
      ..timeStamp = DateTime.now()
      ..unreadCountMap = {}
      ..viewingTimes = []
      ..viewingNotes = []
      ..viewingImageUrls = []
      ..generalImageUrls = []
      ..hisName = post.username
      ..hisPhotoUrl = post.userProfileImageUrl;

    // テンプレートを作成
    final template = PropertyTemplate(
      postId: post.id,
      name: post.condominiumName,
      rent: post.rent,
      location: post.location,
      description: post.description,
      roomType: post.roomType,
      gender: post.gender,
      photoUrls: post.imageUrls,
      nationality: 'Any',
    );

    setState(() {
      _selectedIndex = 0; // チャットタブへ切り替え
      _selectedThread = dummyThread;
      _pendingPropertyTemplate = template; // ★ テンプレートをセットして入力欄に表示させる
    });

    _showSnackBar('Opening chat for ${post.condominiumName}...');
  }
  String _generateChatThreadId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildChatDetailView() {
    if (_selectedThread != null) {
      return IndividualChatScreenWithProvider(
        key: ValueKey(_selectedThread!.id),
        chatThreadId: _selectedThread!.id,
        otherUserUid: _getOtherParticipantId(_selectedThread!, userData.userId),
        otherUserName: _selectedThread!.hisName ?? 'Chat User',
        otherUserPhotoUrl: _selectedThread!.hisPhotoUrl,
        // ★ PendingActionからのテンプレートがあれば渡す
        initialPropertyTemplate: _pendingPropertyTemplate,
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
    
    final List<Widget> pages;
    if (_isAgent) {
      pages = [
        Row( // Index 0: Chat
          children: [
            SizedBox(
              width: 350,
              child: _chatThreadsScreen,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _buildChatDetailView(), 
            ),
          ],
        ),
        _tenantListView,
        _myProfilePage,
      ];
    } else {
      pages = [
        Row( // Index 0: Chat
          children: [
            SizedBox(
              width: 350,
              child: _chatThreadsScreen,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _buildChatDetailView(),
            ),
          ],
        ),
        _discoverScreen,
        _profileScreen,
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
                  _pendingPropertyTemplate = null; // ★ タブ切り替え時にクリア
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
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}