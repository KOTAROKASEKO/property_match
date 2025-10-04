import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/2_tenant_feature/1_discover/model/filter_options.dart';
import 'package:re_conver/common_feature/chat/viewmodel/unread_messages_viewmodel.dart';
import 'package:re_conver/features/2_tenant_feature/1_discover/view/filter_bottom_sheet.dart';
import 'package:re_conver/features/2_tenant_feature/1_discover/view/post_card.dart';
import 'package:re_conver/features/2_tenant_feature/1_discover/viewmodel/discover_viewmodel.dart';


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

  void _showFilterSheet() async {
    final viewModel = context.read<DiscoverViewModel>();
    final newFilters = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          FilterBottomSheet(initialFilters: viewModel.filterOptions),
    );

    if (newFilters != null) {
      viewModel.applyFilters(newFilters);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final viewModel = context.watch<DiscoverViewModel>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () => viewModel.fetchInitialPosts(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: true,
                snap: true,
                pinned: true,
                elevation: 1.0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                title: const Text('Discover'),
                flexibleSpace: FlexibleSpaceBar(
                  background: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search by location or name...',
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.grey, size: 20),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear,
                                            color: Colors.grey, size: 20),
                                        onPressed: () {
                                          _searchController.clear();
                                          viewModel.applySearchQuery('');
                                        },
                                      )
                                    : null,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: viewModel.filterOptions.isClear
                                ? Colors.grey[200]
                                : Colors.deepPurple[100],
                            borderRadius: BorderRadius.circular(25),
                            child: InkWell(
                              onTap: _showFilterSheet,
                              borderRadius: BorderRadius.circular(25),
                              child: const SizedBox(
                                height: 48,
                                width: 48,
                                child: Icon(Icons.filter_list,
                                    color: Colors.black54),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (viewModel.isLoading)
                const SliverFillRemaining(
                  child: _ShimmerPostCard(),
                )
              else if (viewModel.posts.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text("No posts found for your criteria."),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == viewModel.posts.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final post = viewModel.posts[index];
                      return PostCard(
                        post: post,
                        onToggleLike: viewModel.toggleLike,
                        onToggleSave: viewModel.savePost,
                      );
                    },
                    childCount: viewModel.posts.length +
                        (viewModel.isLoadingMore ? 1 : 0),
                  ),
                ),
            ],
          ),
        ),
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