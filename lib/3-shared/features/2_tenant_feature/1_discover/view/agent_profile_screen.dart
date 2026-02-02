// lib/3-shared/features/2_tenant_feature/1_discover/view/agent_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../../../1_agent_feature/1_profile/model/agent_profile_model.dart';
import '../../../../common_feature/chat/view/providerIndividualChat.dart';
import 'post_card.dart';
import '../viewmodel/public_agent_profile_viewmodel.dart';

// ★ Import for ReservationSection
import '../../../reservation/view/reservation_section.dart';

import '../../../../core/model/PostModel.dart';
import 'property_detail_screen.dart';


class AgentProfileScreen extends StatelessWidget {
  final String agentId;

  const AgentProfileScreen({Key? key, required this.agentId}) : super(key: key);

  String _generateChatThreadId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  void _showPostDetails(
    BuildContext context,
    PostModel post,
    PublicAgentProfileViewModel viewModel,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(
          postId: post.id,
          post: post,
        ),
      ),
    );
  }

  void _startChat(
    BuildContext context,
    PostModel post,
    PublicAgentProfileViewModel viewModel,
  ) {
    
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


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PublicAgentProfileViewModel>(
      create: (_) => PublicAgentProfileViewModel(agentId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agent Profile'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Consumer<PublicAgentProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.agentProfile == null) {
              return const Center(child: Text('Agent not found.'));
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ProfileHeader(
                    agentProfile: viewModel.agentProfile!,
                    onStartChat: () {
                      final chatThreadId = _generateChatThreadId(
                          userData.userId, viewModel.agentProfile!.uid);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => IndividualChatScreenWithProvider(
                            otherUserUid: viewModel.agentProfile!.uid,
                            otherUserName: viewModel.agentProfile!.displayName,
                            otherUserPhotoUrl:
                                viewModel.agentProfile!.profileImageUrl,
                            chatThreadId: chatThreadId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // ★★★ RESERVATION SECTION ADDED HERE ★★★
                SliverToBoxAdapter(
                  child: ReservationSection(
                    agentId: agentId,
                    isAgentView: false, // Tenant mode: Book
                  ),
                ),
                // ★★★ END ADDED SECTION ★★★

                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    const double gridBreakpoint = 600.0;
                    final bool useGridView = constraints.asBoxConstraints().maxWidth >= gridBreakpoint;

                    if (viewModel.posts.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 50.0),
                            child: Text(
                              "This agent hasn't posted any listings yet.",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }
                    
                    if (useGridView) {
                      return _buildPostGrid(context, viewModel);
                    } else {
                      return _buildPostList(context, viewModel);
                    }
                  }
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostGrid(BuildContext context, PublicAgentProfileViewModel viewModel) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 350).floor().clamp(1, 4);

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
              onStartChat: (post) => _startChat(context, post, viewModel),
              onTap: () => _showPostDetails(context, post, viewModel),
            );
          },
          childCount: viewModel.posts.length,
        ),
      ),
    );
  }

  Widget _buildPostList(BuildContext context, PublicAgentProfileViewModel viewModel) {
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
              onStartChat: (post) => _startChat(context, post, viewModel),
              onTap: () => _showPostDetails(context, post, viewModel),
            ));
          },
          childCount: viewModel.posts.length,
        ),
      );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AgentProfile agentProfile;
  final VoidCallback onStartChat;

  const _ProfileHeader(
      {Key? key, required this.agentProfile, required this.onStartChat})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: agentProfile.profileImageUrl.isNotEmpty
                ? NetworkImage(agentProfile.profileImageUrl)
                : null,
            child: agentProfile.profileImageUrl.isEmpty
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            agentProfile.displayName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            agentProfile.bio,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onStartChat,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Start Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}