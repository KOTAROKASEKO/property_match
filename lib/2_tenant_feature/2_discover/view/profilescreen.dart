import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/post_model.dart';
import 'package:re_conver/2_tenant_feature/3_profile/view/edit_profile_screen.dart';
import 'package:re_conver/2_tenant_feature/2_discover/view/post_card.dart';
import 'package:re_conver/2_tenant_feature/2_discover/view/saved_posts_tab.dart';
import 'package:re_conver/2_tenant_feature/2_discover/viewmodel/discover_viewmodel.dart';
import 'package:re_conver/2_tenant_feature/3_profile/viewmodel/profile_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => DiscoverViewModel()),
      ],
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.myPosts.isEmpty) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                viewModel.userProfile.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    /* TODO: Open settings menu */
                  },
                ),
              ],
            ),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(child: _ProfileHeader(viewModel: viewModel)),
                ];
              },
              body: Column(
                children: [
                  const TabBar(
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on_outlined)),
                      Tab(icon: Icon(Icons.bookmark_border_outlined)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _MyPostsGrid(),
                        const SavedPostsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileViewModel viewModel;
  const _ProfileHeader({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final profile = viewModel.userProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  // ViewModelのメソッドを呼び出す
                  context.read<ProfileViewModel>().updateProfileImage();
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: profile.profileImageUrl.isNotEmpty
                      ? NetworkImage(profile.profileImageUrl)
                      : null,
                  child: profile.profileImageUrl.isEmpty
                      ? Icon(Icons.person,
                          size: 40, color: Colors.grey.shade600)
                      : null,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Posts", profile.postCount.toString()),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (profile.displayName.isNotEmpty)
                Text(
                  profile.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 4),
              if (profile.bio.isNotEmpty)
                Text(
                  profile.bio,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: OutlinedButton(
            onPressed: () {
              // **MODIFIED: Navigate to Edit Profile Screen**
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: viewModel, // Pass the existing ViewModel
                    child: const EditProfileScreen(),
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Edit Profile'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

class _MyPostsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final posts = viewModel.myPosts;

    if (viewModel.isLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text("No Posts Yet",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchMyPosts(isInitial: true),
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final Post post = posts[index];
          return PostCard(post: post);
        },
      ),
    );
  }
}