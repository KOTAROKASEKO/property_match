import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/view/shimmer_postcard.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/2_ai_chat/view/ai_chat_main_layout.dart';
import 'package:re_conver/3-shared/features/authentication/auth_service.dart';
import 'package:re_conver/l10n/app_localizations.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../../../../common_feature/chat/view/providerIndividualChat.dart';
import 'post_card.dart';
import '../viewmodel/discover_viewmodel.dart';
import '../model/filter_options.dart';
import 'discover_filter_panel.dart';
import 'filter_bottom_sheet.dart';
import '../../../../core/model/PostModel.dart';
import 'property_detail_screen.dart';

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
  bool get wantKeepAlive => true;

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

  void _showFilterSheet() async {
    final newFilters = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: FilterBottomSheet(
              initialFilters: context.read<DiscoverViewModel>().filterOptions),
        ),
      ),
    );

    if (newFilters != null && mounted) {
      context.read<DiscoverViewModel>().applyFilters(newFilters);
    }
  }

  void _showPostDetails(PostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(
          postId: post.id,
          post: post,
        ),
      ),
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
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: isWideScreen
                    ? _buildWideLayout()
                    : _buildNarrowLayout(),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildNarrowAppBar() {
    final l = AppLocalizations.of(context)!;
    return AppBar(
      title: Row(children: [
        const Icon(Icons.travel_explore, color: Colors.white),
        const SizedBox(width: 10),
        Text(l.common_discover, style: const TextStyle(color: Colors.white)),
      ]),
      backgroundColor: Colors.deepPurple,
      elevation: 1.0,
      foregroundColor: Colors.white,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildSearchBar(l),
        ),
      ),
      actions: [
        IconButton(
            onPressed: () async {
              final aiFilters = await Navigator.push<FilterOptions>(
                context,
                MaterialPageRoute(builder: (_) => const AIChatMainLayout()),
              );

              if (aiFilters != null && context.mounted) {
                Navigator.of(context).pop(aiFilters);
              }
            },
            icon: const Icon(Icons.auto_awesome, color: Colors.amber)),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterSheet,
          tooltip: l.discover_filtersTitle,
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations l) {
    return TextField(
      textInputAction: TextInputAction.search,
      onSubmitted: (query) {
        context.read<DiscoverViewModel>().applySearchQuery(query);
        FocusScope.of(context).unfocus();
      },
      onEditingComplete: () {
        context.read<DiscoverViewModel>().applySearchQuery(_searchController.text);
        FocusScope.of(context).unfocus();
      },
      controller: _searchController,
      decoration: InputDecoration(
        hintText: l.discover_searchHint,
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

  Widget _buildWideLayout() {
    final l = AppLocalizations.of(context)!;
    return Row(
      children: [
        const SizedBox(
          width: 300,
          child: DiscoverFilterPanel(),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: _buildSearchBar(l),
              ),
              Expanded(
                child: RefreshIndicator(
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

  Widget _buildNarrowLayout() {
    return RefreshIndicator(
      onRefresh: () => context.read<DiscoverViewModel>().fetchInitialPosts(),
      child: _buildPostContentScrollView(),
    );
  }

  Widget _buildPostContentScrollView() {
    final viewModel = context.watch<DiscoverViewModel>();
    final l = AppLocalizations.of(context)!;

    return LayoutBuilder(builder: (context, constraints) {
      const double gridBreakpoint = 600.0;
      final bool useGridView = constraints.maxWidth >= gridBreakpoint;
      final shimmerCount = useGridView ? 8 : 4;
      final crossAxisCount = (constraints.maxWidth / 400).floor().clamp(1, 4);

      return CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (viewModel.isLoading && viewModel.posts.isEmpty)
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
                      childCount: shimmerCount,
                    ),
                  )
          else if (viewModel.posts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l.discover_noPostsFound,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else if (useGridView)
            _buildPostGrid(viewModel, constraints)
          else
            _buildPostList(viewModel),
          if (viewModel.isLoadingMore)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildPostGrid(DiscoverViewModel viewModel, BoxConstraints constraints) {
    final crossAxisCount = (constraints.maxWidth / 400).floor().clamp(1, 4);

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 0.70,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final post = viewModel.posts[index];
            return PostCard(
              post: post,
              onToggleLike: viewModel.toggleLike,
              onToggleSave: viewModel.savePost,
              onStartChat: _startChat,
              onTap: () => _showPostDetails(post),
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: PostCard(
              post: post,
              onToggleLike: viewModel.toggleLike,
              onToggleSave: viewModel.savePost,
              onStartChat: _startChat,
              onTap: () => _showPostDetails(post),
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
        payload: {'post': post},
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
      nationality: 'Any',
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