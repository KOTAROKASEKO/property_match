import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../1_agent_feature/1_profile/model/agent_profile_model.dart';
import '../../../../common_feature/chat/view/providerIndividualChat.dart';
import '../../../1_agent_feature/chat_template/model/property_template.dart';
import 'post_card.dart';
import '../viewmodel/public_agent_profile_viewmodel.dart';
import '../../../authentication/userdata.dart';

class AgentProfileScreen extends StatelessWidget {
  final String agentId;

  const AgentProfileScreen({Key? key, required this.agentId}) : super(key: key);

  String _generateChatThreadId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }



    @override
    Widget build(BuildContext context) {
    return ChangeNotifierProvider<PublicAgentProfileViewModel>(
      create: (_) => PublicAgentProfileViewModel(agentId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agent Profile'),
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
                SliverList(
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
                    childCount: viewModel.posts.length,
                  ),
                ),
              ],
            );
          },
        ),
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
          ),
        ],
      ),
    );
  }
}