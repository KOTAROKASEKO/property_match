// lib/3-shared/features/2_tenant_feature/1_discover/view/post_detail_bottomsheet.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/view/comment_bottomsheet.dart';
import 'package:re_conver/3-shared/features/authentication/auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;

// ★ 1. PostActionsViewModel をインポート
import '../../../../common_feature/post_actions_viewmodel.dart';
import '../../../../core/model/PostModel.dart';
// ★ 2. DiscoverViewModel のインポートを削除 (またはコメントアウト)
// import '../viewmodel/discover_viewmodel.dart';
import 'agent_profile_screen.dart';
import 'full_pic_screen.dart';

class PostDetailBottomSheet extends StatefulWidget {
  final PostModel post;
  // ★ 3. onStartChat をパラメータとして追加
  final Function(PostModel) onStartChat;

  const PostDetailBottomSheet({
    super.key,
    required this.post,
    required this.onStartChat, // ★ 4. コンストラクタに追加
  });

  @override
  State<PostDetailBottomSheet> createState() => _PostDetailBottomSheetState();
}

class _PostDetailBottomSheetState extends State<PostDetailBottomSheet> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    // ★ 5. DiscoverViewModel -> PostActionsViewModel に変更
    final viewModel = context.watch<PostActionsViewModel>();
    final post = widget.post;

    return Column(
      children: [
        // 1. Draggable Handle
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        // 2. Scrollable Content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              if (post.imageUrls.isNotEmpty) _buildImageCarousel(context, post),
              const SizedBox(height: 16),
              _buildHeader(context, post),
              const SizedBox(height: 16),
              _buildInfoChips(post),
              const Divider(height: 32),
              _buildDescription(post),
              const Divider(height: 32),
              _buildAgentHeader(context, post),
            ],
          ),
        ),

        // 3. Bottom Action Bar
        _buildActionBar(context, viewModel, post),
      ],
    );
  }

  // ... ( _buildImageCarousel, _buildHeader, _buildInfoChips, _buildDescription, _buildAgentHeader は変更なし) ...
    Widget _buildImageCarousel(BuildContext context, PostModel post) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 16 / 10,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
            items: post.imageUrls.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return Hero(
                    tag: item,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageView(
                              imageUrl: item,
                            ),
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: item,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          if (post.imageUrls.length > 1)
            Positioned(
              bottom: 12.0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(post.imageUrls.length, (index) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PostModel post) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.condominiumName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'RM ${post.rent.toStringAsFixed(0)} / month',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        // Like/Save buttons can go here if needed
      ],
    );
  }

  Widget _buildInfoChips(PostModel post) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        _buildInfoChip(Icons.meeting_room_outlined, post.roomType),
        _buildInfoChip(Icons.person_outline, '${post.gender} Unit'),
        if (post.durationStart != null && post.durationMonths != null)
          _buildInfoChip(
            Icons.date_range_outlined,
            '${DateFormat.yMd().format(post.durationStart!)} - ${post.durationMonths!} months',
          ),
        if (post.hobbies.isNotEmpty)
          ...post.hobbies
              .map((hobby) => _buildInfoChip(Icons.interests_outlined, hobby))
              .toList(),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.deepPurple),
      label: Text(
        label,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 102, 102, 102)),
      ),
      backgroundColor: Colors.deepPurple.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildDescription(PostModel post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          post.description.isEmpty
              ? 'No description provided.'
              : post.description,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAgentHeader(BuildContext context, PostModel post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Listed by',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            if (FirebaseAuth.instance.currentUser == null) {
              showSignInModal(context);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AgentProfileScreen(agentId: post.userId),
                ),
              );
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: post.userProfileImageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(post.userProfileImageUrl)
                    : null,
                child: post.userProfileImageUrl.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Posted ${timeago.format(post.timestamp.toDate())}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildActionBar(
      BuildContext context, PostActionsViewModel viewModel, PostModel post) { // ★ 6. ViewModel の型を変更
    return Container(
      padding:
          const EdgeInsets.fromLTRB(16, 12, 16, 16).copyWith(bottom: 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          // Action Icons (Save, Comment)
          IconButton(
            icon: Icon(
              post.isSaved ? Icons.bookmark : Icons.bookmark_border,
              color:
                  post.isSaved ? Theme.of(context).primaryColor : Colors.grey[700],
              size: 28,
            ),
            onPressed: () {
              if (FirebaseAuth.instance.currentUser == null) {
                showSignInModal(context);
              } else {
                viewModel.savePost(post.id);
              }
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[700], size: 28),
            onPressed: () {
              if (FirebaseAuth.instance.currentUser == null) {
                showSignInModal(context);
              } else {
                // Close this sheet first
                Navigator.of(context).pop(); 
                // Then show the comment sheet
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CommentBottomSheet(postId: post.id),
                );
              }
            },
          ),
          const SizedBox(width: 16),

          // Main Action Button
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Inquire'),
              // ★ 7. viewModel.onStartChat! -> widget.onStartChat に変更
              onPressed: () {
                // The auth check is now handled by the caller,
                // but we can just call the function.
                widget.onStartChat(post);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}