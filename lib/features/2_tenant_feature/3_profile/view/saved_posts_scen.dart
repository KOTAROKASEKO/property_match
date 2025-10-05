import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/features/2_tenant_feature/1_discover/view/post_card.dart';
import 'package:re_conver/features/2_tenant_feature/3_profile/viewmodel/saved_posts_viewmodel.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SavedPostsViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved Listings'),
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
              child: ListView.builder(
                itemCount: viewModel.savedPosts.length,
                itemBuilder: (context, index) {
                  final post = viewModel.savedPosts[index];
                  // 既存のPostCardウィジェットを再利用します
                  return PostCard(
                    post: post,
                    onToggleLike: viewModel.toggleLike,
                    onToggleSave: viewModel.savePost,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}