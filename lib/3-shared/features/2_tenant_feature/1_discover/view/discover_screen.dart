// lib/3-shared/features/2_tenant_feature/1_discover/view/discover_screen.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // ★★★ ADDED ★★★
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/common_feature/post_actions_viewmodel.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/view/shimmer_postcard.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/2_ai_chat/view/ai_chat_main_layout.dart';
import 'package:re_conver/3-shared/features/authentication/auth_service.dart'; // ★★★ ADDED ★★★
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../../../../common_feature/chat/view/providerIndividualChat.dart';
import 'post_card.dart';
import '../viewmodel/discover_viewmodel.dart';
import '../model/filter_options.dart';
import 'discover_filter_panel.dart';
import 'filter_bottom_sheet.dart';
import '../../../../core/model/PostModel.dart';
import 'post_detail_bottomsheet.dart';


class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiscoverViewModel(),
      child: const _DiscoverView(),
    );
  }
}

class _DiscoverView extends StatefulWidget {
  const _DiscoverView();

  @override
  State<_DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<_DiscoverView>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  final _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (mounted) {
          context.read<DiscoverViewModel>().fetchMorePosts();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _generateChatThreadId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  // ★★★ ボトムシート表示用のメソッド (Filter) ★★★
  void _showFilterSheet() async {
    // ViewModel は initState で取得済み
    final newFilters = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // DraggableSheet の背景を活かす
      builder: (_) => DraggableScrollableSheet( // DraggableSheet を追加
        initialChildSize: 0.9, // 開始時の高さ
        maxChildSize: 0.9,     // 最大の高さ
        expand: false,
        builder: (_, scrollController) => Container( // 角丸と背景色のため
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: FilterBottomSheet(initialFilters: context.read<DiscoverViewModel>().filterOptions),
        ),
      ),
    );

    if (newFilters != null && mounted) { // mountedチェック推奨
      context.read<DiscoverViewModel>().applyFilters(newFilters); // ★変更
    }
  }
  
  void _showPostDetails(PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ChangeNotifierProvider<PostActionsViewModel>.value(
          // ★ 修正: _viewModel を context.read<DiscoverViewModel>() に変更
          value: context.read<DiscoverViewModel>(),
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: PostDetailBottomSheet(
                  post: post,
                  onStartChat: _startChat,
                ),
              );
            },
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const double wideScreenThreshold = 800.0;
        final bool isWideScreen = constraints.maxWidth >= wideScreenThreshold;
        return Scaffold(
          appBar: isWideScreen ? null : _buildNarrowAppBar(),
          backgroundColor: Colors.grey[100],
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWideScreen ? 1400 : double.infinity,
              ),
              child: GestureDetector( // 画面タップでフォーカス解除
                onTap: () => FocusScope.of(context).unfocus(),
                child: isWideScreen
                    ? _buildWideLayout() // ★ ワイドスクリーン用レイアウト
                    : _buildNarrowLayout(), // ★ ナロースクリーン用レイアウト (AppBarなし)
              ),
            ),
          ),
        );
      },
    );
  }

  // --- ★★★ ナロースクリーン用 AppBar ★★★ ---
  AppBar _buildNarrowAppBar() {
    return AppBar(
      // AppBarの内容は従来のSliverAppBarから移動
      // flexibleSpace は使わない
      title: const Row(children: [
        Icon(Icons.travel_explore, color: Colors.white),
        SizedBox(width: 10),
        Text('Discover', style: TextStyle(color: Colors.white)),
      ]),
      backgroundColor: Colors.deepPurple,
      elevation: 1.0,
      foregroundColor: Colors.white,
      bottom: PreferredSize( // 検索バーを AppBar の bottom に配置
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildSearchBar(), // 検索バー部分をメソッド化
        ),
      ),
      actions: [ // フィルターボタンを actions に配置
      IconButton(
          onPressed: ()async{
          final aiFilters = await Navigator.push<FilterOptions>(
          context,
          // ★ AIChatScreen ではなく AIChatListScreen を呼び出す
          MaterialPageRoute(builder: (_) => const AIChatMainLayout()),
        );
        
        if (aiFilters != null && context.mounted) {
          // AIチャット画面からフィルターが返ってきたら、このボトムシートも閉じる
          Navigator.of(context).pop(aiFilters);
        }
        }, icon: Icon(Icons.auto_awesome, color: Colors.amber,)),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterSheet, // ★ ボトムシート表示メソッドを呼び出す
          tooltip: 'Filters',
        ),
        
      ],
    );
  }

  // --- ★★★ 検索バー部分を抽出 ★★★ ---
  Widget _buildSearchBar() {
    return TextField(
      textInputAction: TextInputAction.search, // キーボードに検索ボタンを表示
      onSubmitted: (query) {
        // ★ 直接 context.read を使う
        
        context.read<DiscoverViewModel>().applySearchQuery(query);
        FocusScope.of(context).unfocus();
      },
      onEditingComplete: () {
        // ★ 直接 context.read を使う
        context.read<DiscoverViewModel>().applySearchQuery(_searchController.text);
        FocusScope.of(context).unfocus();
      },
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Bukit Jalil LRT, APU, Sunway Pyramid',
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      ),
    );
  }

  // --- ★★★ ワイドスクリーン用レイアウト (Row) ★★★ ---
  Widget _buildWideLayout() {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: DiscoverFilterPanel(),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: _buildSearchBar(),
              ),
              Expanded(
                child: RefreshIndicator(
                  // ★ 修正: _viewModel.fetchInitialPosts() を以下に変更
                  onRefresh: () => context.read<DiscoverViewModel>().fetchInitialPosts(),
                  child: _buildPostContentScrollView(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // --- ★★★ ナロースクリーン用レイアウト (AppBarなしのコンテンツ部分) ★★★ ---
  Widget _buildNarrowLayout() {
    return RefreshIndicator(
      // ★ 修正: _viewModel.fetchInitialPosts() を以下に変更
      onRefresh: () => context.read<DiscoverViewModel>().fetchInitialPosts(),
      child: _buildPostContentScrollView(),
    );
  }


  // --- ★★★ 投稿リスト表示の CustomScrollView 部分を共通化 ★★★ ---
  Widget _buildPostContentScrollView() {
    final viewModel = context.watch<DiscoverViewModel>();

    return LayoutBuilder(
      builder: (context, constraints) {
          const double gridBreakpoint = 600.0;
          final bool useGridView = constraints.maxWidth >= gridBreakpoint;

          // ★ Shimmerの表示数を計算 (画面サイズに合わせて調整)
          final shimmerCount = useGridView ? 8 : 4; 
          
          // ★ Gridの場合の列数計算 (後でShimmerでも使うためここで計算)
          final crossAxisCount = (constraints.maxWidth / 400).floor().clamp(1, 4);

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // コンテンツエリア
              if (viewModel.isLoading && viewModel.posts.isEmpty) 
                // ★★★ 修正: ローディング中は Shimmer を表示 ★★★
                useGridView 
                  ? SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                          childAspectRatio: 0.70,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const ShimmerPostCard(),
                          childCount: shimmerCount,
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: ShimmerPostCard(),
                        ),
                        childCount: shimmerCount, // リスト形式なら4つくらい表示
                      ),
                    )
              else if (viewModel.posts.isEmpty)
                // (ここは変更なし: No posts found)
                const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No posts found matching your criteria.\nTry adjusting the filters.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                )
              else if (useGridView) 
                _buildPostGrid(viewModel, constraints)
              else 
                _buildPostList(viewModel),

              // もっと読み込むインジケータ (ここも必要なら小さなShimmerにできますが、Indicatorで十分なことが多いです)
              if (viewModel.isLoadingMore)
                SliverToBoxAdapter(
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          );
        }
    );
  }
  
  Widget _buildPostGrid(DiscoverViewModel viewModel, BoxConstraints constraints) {
    final crossAxisCount = (constraints.maxWidth / 400).floor().clamp(1, 4); // 最小1列、最大4列

    return SliverPadding(
      padding: const EdgeInsets.all(16.0), // Gridの外側の余白
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // 計算した列数
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 0.70, // カードの縦横比
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final post = viewModel.posts[index];
            return PostCard(
              post: post,
              onToggleLike: viewModel.toggleLike,
              onToggleSave: viewModel.savePost,
              onStartChat: _startChat, // ★ チャット開始メソッドを渡す
              onTap: () => _showPostDetails(post), // ★★★ PASS THE ONTAP HANDLER ★★★
            );
          },
          childCount: viewModel.posts.length,
        ),
      ),
    );
  }

  Widget _buildPostList(DiscoverViewModel viewModel) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final post = viewModel.posts[index];
          return Padding( // リスト表示時の左右の余白を追加
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: PostCard(
              post: post,
              onToggleLike: viewModel.toggleLike,
              onToggleSave: viewModel.savePost,
              onStartChat: _startChat, // ★ チャット開始メソッドを渡す
              onTap: () => _showPostDetails(post), // ★★★ PASS THE ONTAP HANDLER ★★★
            ),
          );
        },
        childCount: viewModel.posts.length,
      ),
    );
  }


  void _startChat(PostModel post) {
    if (FirebaseAuth.instance.currentUser == null) {
      pendingAction = PendingAction(
        type: PendingActionType.chatWithAgent,
        payload: {'post': post}, // PostModelを渡す
      );
      
      showSignInModal(context);
      return;
    }
    
    final chatThreadId = _generateChatThreadId(userData.userId, post.userId);
    final propertyTemplate = PropertyTemplate(
      postId: post.id,
      name: post.condominiumName,
      rent: post.rent,
      location: post.location,
      description: post.description,
      roomType: post.roomType,
      gender: post.gender,
      photoUrls: post.imageUrls,
      nationality: 'Any', // Consider adding nationality to PostModel if needed
    );

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } 

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IndividualChatScreenWithProvider(
          chatThreadId: chatThreadId,
          otherUserUid: post.userId,
          otherUserName: post.username,
          otherUserPhotoUrl: post.userProfileImageUrl,
          initialPropertyTemplate: propertyTemplate,
        ),
      ),
    );
  }
}