// lib/features/2_tenant_feature/1_discover/view/discover_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../../../../common_feature/chat/view/providerIndividualChat.dart';
import '../../../../common_feature/chat/viewmodel/unread_messages_viewmodel.dart';
import 'post_card.dart';
import '../viewmodel/discover_viewmodel.dart';


class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiscoverViewModel()),
        ChangeNotifierProvider(create: (_) => UnreadMessagesViewModel()),
      ],
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
  bool get wantKeepAlive => true;
  final _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<DiscoverViewModel>();

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 700), () {
        if (mounted) {
          viewModel.applySearchQuery(_searchController.text);
        }
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (mounted) {
          viewModel.fetchMorePosts();
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

  // ★ Helper method from step 1
  String _generateChatThreadId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final viewModel = context.watch<DiscoverViewModel>();
    return LayoutBuilder(
      builder: (context, constraints) {
        // 画面幅が広いかどうかの閾値（この値は調整してください）
        const double wideScreenThreshold = 800.0;
        final bool isWideScreen = constraints.maxWidth > wideScreenThreshold;

        // 画面が広い場合、コンテンツが広がりすぎないように最大幅を設定し中央に寄せます
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // モダンなWebサイトのように最大幅を設定します（例: 1400dp）
              maxWidth: isWideScreen ? 1400 : double.infinity,
            ),
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                body: RefreshIndicator(
                  onRefresh: () => viewModel.fetchInitialPosts(),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // SliverAppBarは既存のまま
                      SliverAppBar(
                        expandedHeight: 120.0,
                        floating: true,
                        snap: true,
                        pinned: true,
                        elevation: 1.0,
                        backgroundColor: Colors.deepPurple,
                        title: Row(children:[
                          const Icon(Icons.home_filled,
                          color: Colors.white,
                          ),
                          const SizedBox(width: 10,),
                        const Text('Discover', style:TextStyle(color: Colors.white)),
                        ]),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              // 検索バーとフィルターボタン
                              child: Row(
                                // ... (既存のTextFieldとFilterボタンのロジックはそのまま)
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // --- ★ 変更点：コンテンツエリアの分岐 ---
                      
                      if (viewModel.isLoading)
                        const SliverFillRemaining(
                          // TODO: ワイドスクリーン用のグリッド型シマーローダーを
                          // 作成すると、よりクリーンになります。
                          child: _ShimmerPostCard(),
                        )
                      else if (viewModel.posts.isEmpty)
                        const SliverFillRemaining(
                          child: Center(
                            child: Text("No posts found for your criteria."),
                          ),
                        )
                      else if (isWideScreen)
                        // 【ワイドスクリーン用】グリッドレイアウト
                        _buildWideScreenGrid(viewModel)
                      else
                        // 【モバイル用】従来のリストレイアウト
                        _buildNarrowScreenList(viewModel),

                      // 「もっと読み込む」インジケータ
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  
  }
  
    Widget _buildWideScreenGrid(DiscoverViewModel viewModel) {
    return SliverPadding(
      // グリッドの外側に余白を設定
      padding: const EdgeInsets.all(24.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 450.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
          childAspectRatio: 0.70,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final post = viewModel.posts[index];
            return PostCard(
              post: post,
              onToggleLike: viewModel.toggleLike,
              onToggleSave: viewModel.savePost,
              onStartChat: (post) {
                // (onStartChatのロジックは既存のまま)
              },
            );
          },
          childCount: viewModel.posts.length,
        ),
      ),
    );
  }

  // --- ★ 新規追加：モバイル用のリストを構築するメソッド（既存のロジックを移動） ---
  Widget _buildNarrowScreenList(DiscoverViewModel viewModel) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          
          final post = viewModel.posts[index];
          return PostCard(
            post: post,
            onToggleLike: viewModel.toggleLike,
            onToggleSave: viewModel.savePost,
            onStartChat: (post) {
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
                nationality: 'Any',
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
            },
          );
        },
        // 「もっと読み込む」のインジケータは別のSliverToBoxAdapterで
        // 表示するため、childCountを +1 する必要はありません。
        childCount: viewModel.posts.length,
      ),
    );
    }
}

class _ShimmerPostCard extends StatelessWidget {
  const _ShimmerPostCard();

  @override
  Widget build(BuildContext context) {
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 16, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(width: 80, height: 12, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.width - 8,
            width: double.infinity,
            color: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 14, color: Colors.white),
                const SizedBox(height: 8),
                Container(
                    width: double.infinity, height: 14, color: Colors.white),
                const SizedBox(height: 4),
                Container(width: 150, height: 14, color: Colors.white),
              ],
            ),
          )
        ],
      ),
    );
  
  }
}