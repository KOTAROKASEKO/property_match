// lib/3-shared/features/2_tenant_feature/3_profile/view/saved_posts_scen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../1_discover/view/post_card.dart';
import '../viewmodel/saved_posts_viewmodel.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SavedPostsViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved Listings'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: Consumer<SavedPostsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.savedPosts.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'You haven\'t saved any listings yet.\nTap the bookmark icon on a listing to save it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.fetchSavedPosts(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // レスポンシブ対応の閾値
                  const double gridBreakpoint = 600.0;
                  final bool useGridView = constraints.maxWidth >= gridBreakpoint;

                  if (useGridView) {
                    // --- ワイド画面 (Grid表示) ---
                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400, // カードの最大幅
                        mainAxisSpacing: 16.0,
                        crossAxisSpacing: 16.0,
                        childAspectRatio: 0.70, // PostCardのアスペクト比に合わせて調整
                      ),
                      itemCount: viewModel.savedPosts.length,
                      itemBuilder: (context, index) {
                        final post = viewModel.savedPosts[index];
                        return PostCard(
                          post: post,
                          onToggleLike: viewModel.toggleLike,
                          onToggleSave: viewModel.savePost,
                        );
                      },
                    );
                  } else {
                    // --- モバイル画面 (List表示) ---
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      itemCount: viewModel.savedPosts.length,
                      itemBuilder: (context, index) {
                        final post = viewModel.savedPosts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: PostCard(
                            post: post,
                            onToggleLike: viewModel.toggleLike,
                            onToggleSave: viewModel.savePost,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}