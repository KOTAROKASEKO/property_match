// lib/features/2_tenant_feature/1_discover/view/discover_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../../../../common_feature/chat/view/providerIndividualChat.dart';
// import '../../../../common_feature/chat/viewmodel/unread_messages_viewmodel.dart'; // Discover doesn't need this directly
import 'post_card.dart';
import '../viewmodel/discover_viewmodel.dart';
// ★★★ インポート追加 ★★★
import '../model/filter_options.dart';
import 'discover_filter_panel.dart'; // 左側フィルターパネル
import 'filter_bottom_sheet.dart';   // ボトムシート
import '../../../../core/model/PostModel.dart'; // PostModel のインポートを追加
// ★★★ ------------- ★★★


class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ViewModel Provider はそのまま
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
  // ★ ViewModel への参照を State 内で保持 (initStateで初期化)
  late DiscoverViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // ★ initState で ViewModel を取得
    _viewModel = context.read<DiscoverViewModel>();



    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (mounted) {
          // ★ _viewModel を使用
          _viewModel.fetchMorePosts();
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

  // ★★★ ボトムシート表示用のメソッドを追加 ★★★
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
          // 既存の FilterBottomSheet ウィジェットを再利用
          // FilterBottomSheet は内部で ListView を持つため scrollController は不要
          child: FilterBottomSheet(initialFilters: _viewModel.filterOptions),
        ),
      ),
    );

    if (newFilters != null) {
      _viewModel.applyFilters(newFilters);
    }
  }
  // ★★★ ------------- ★★★


  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin のため

    // watch で ViewModel の変更を監視
    // final viewModel = context.watch<DiscoverViewModel>(); // initState で取得済みに変更

    // ★★★ LayoutBuilder で画面幅を判定 ★★★
    return LayoutBuilder(
      builder: (context, constraints) {
        // --- 画面幅の閾値 ---
        const double wideScreenThreshold = 800.0;
        final bool isWideScreen = constraints.maxWidth >= wideScreenThreshold;

        // --- Scaffold または Row を返す ---
        return Scaffold(
          // AppBar は縦長画面でのみ表示
          appBar: isWideScreen ? null : _buildNarrowAppBar(),
          backgroundColor: Colors.grey[100], // 背景色を設定
          body: Center( // ワイドスクリーン時に中央寄せ
            child: ConstrainedBox( // ワイドスクリーン時の最大幅を設定
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
        _viewModel.applySearchQuery(query); // Enterキーで検索を実行
      },
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search properties or locations...',
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
        // --- 左側: フィルターパネル ---
        SizedBox(
          width: 300, // 固定幅 または constraints.maxWidth * 0.3 など
          child: DiscoverFilterPanel(), // 作成したフィルターパネル
        ),
        const VerticalDivider(width: 1, thickness: 1),
        // --- 右側: 投稿リスト ---
        Expanded(
          child: Column( // 検索バーを追加するために Column に変更
            children: [
              // 検索バー (AppBarの代わりにここに配置)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // 上下の Padding を調整
                child: _buildSearchBar(),
              ),
              // 投稿リスト部分
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _viewModel.fetchInitialPosts(),
                  // CustomScrollView を直接配置 (AppBarなし)
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
      onRefresh: () => _viewModel.fetchInitialPosts(),
      // CustomScrollView を直接配置 (AppBarは Scaffold にある)
      child: _buildPostContentScrollView(),
    );
  }


  // --- ★★★ 投稿リスト表示の CustomScrollView 部分を共通化 ★★★ ---
  Widget _buildPostContentScrollView() {
    // ViewModel を再度 watch (build メソッド内で変更を検知するため)
     final viewModel = context.watch<DiscoverViewModel>(); // Use watch here

    // 画面幅を LayoutBuilder で取得 (Grid表示の切り替えのため)
    return LayoutBuilder(
      builder: (context, constraints) {
          const double gridBreakpoint = 600.0; // Grid表示に切り替える幅
          final bool useGridView = constraints.maxWidth >= gridBreakpoint;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // コンテンツエリア
              if (viewModel.isLoading && viewModel.posts.isEmpty) // 初期ロード中
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                  // child: _ShimmerPostCard(), // Or Shimmer
                )
              else if (viewModel.posts.isEmpty)
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
              else if (useGridView) // ★ Grid表示
                _buildPostGrid(viewModel, constraints) // GridView を構築
              else // ★ List表示
                _buildPostList(viewModel), // ListView を構築

              // もっと読み込むインジケータ
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


  // --- ★ GridView 構築メソッド ---
  Widget _buildPostGrid(DiscoverViewModel viewModel, BoxConstraints constraints) {
     // 画面幅に基づいて列数を計算 (例)
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
            );
          },
          childCount: viewModel.posts.length,
        ),
      ),
    );
  }

  // --- ★ ListView 構築メソッド (旧 _buildNarrowScreenList) ---
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
            ),
          );
        },
        childCount: viewModel.posts.length,
      ),
    );
  }

  // --- ★ チャット開始のロジックをメソッド化 ---
  void _startChat(PostModel post) {
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

  // --- ( Shimmer Widget は変更なし ) ---
  // ... _ShimmerPostCard ...
}



