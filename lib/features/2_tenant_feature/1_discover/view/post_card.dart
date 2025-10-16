// lib/features/2_tenant_feature/1_discover/view/post_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:re_conver/app/debug_print.dart';
import 'package:re_conver/core/model/PostModel.dart';
import 'package:re_conver/features/2_tenant_feature/1_discover/view/agent_profile_screen.dart';
import 'package:re_conver/features/2_tenant_feature/1_discover/view/comment_bottomsheet.dart';
import 'package:re_conver/features/2_tenant_feature/1_discover/view/full_pic_screen.dart';
import 'package:re_conver/features/authentication/auth_service.dart';
import 'package:rive/rive.dart' hide Image;
import 'package:timeago/timeago.dart' as timeago;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  // Define function parameters for the actions
  final Function(String) onToggleLike;
  final Function(String) onToggleSave;
  final Function(PostModel)? onStartChat; // ★ 追加

  const PostCard({
    super.key,
    required this.post,
    required this.onToggleLike,
    required this.onToggleSave,
    this.onStartChat, // ★ 追加
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentPage = 0;
  Artboard? _riveArtboard;
  SMIInput<bool>? _isLikedInput;

  @override
  void initState() {
    super.initState();
    rootBundle.load('assets/like.riv').then(
      (data) async {
        try {
          final file = RiveFile.import(data);
          final artboard = file.mainArtboard;
          var controller =
              StateMachineController.fromArtboard(artboard, 'State Machine 1');
          if (controller != null) {
            artboard.addController(controller);
            _isLikedInput = controller.findInput<bool>('isLiked');
            _isLikedInput?.value = widget.post.isLikedByCurrentUser;
          }
          setState(() => _riveArtboard = artboard);
        } catch (e) {
          print(e);
        }
      },
    );
  }

  void _sharePost() {
    final post = widget.post;
    final String textToShare = 'Check out this listing on Re:Conver:\n\n'
        '🏠 *Property:* ${post.condominiumName}\n'
        '💰 *Rent:* RM ${post.rent.toStringAsFixed(0)}/month\n'
        '🚪 *Room Type:* ${post.roomType}\n\n'
        '${post.description}\n\n'
        'View more in the app!';
    Share.share(textToShare);
  }

  @override
  Widget build(BuildContext context) {
    _isLikedInput?.value = widget.post.isLikedByCurrentUser;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(context),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
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
          items: widget.post.imageUrls.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Hero(
                  tag: item, // Heroアニメーションのためのタグ
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
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        if (widget.post.imageUrls.length > 1)
          Positioned(
            bottom: 8.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.post.imageUrls.length, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  // FIXED: Changed parameter type from DiscoverViewModel to PostActionsViewModel
   Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.condominiumName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'RM ${widget.post.rent.toStringAsFixed(0)}',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildInfoChip(Icons.meeting_room_outlined, widget.post.roomType),
              _buildInfoChip(Icons.person_outline, '${widget.post.gender} Unit'),
              if (widget.post.durationStart != null && widget.post.durationEnd != null)
                _buildInfoChip(
                  Icons.date_range_outlined,
                  '${DateFormat.yMd().format(widget.post.durationStart!)} - ${DateFormat.yMd().format(widget.post.durationEnd!)}',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.post.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildUserHeader(context),
              _buildActionButtons(context),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Inquire'),
              onPressed: () {
                if (FirebaseAuth.instance.currentUser == null) {
                  showSignInModal(context);
                } else {
                  widget.onStartChat!(widget.post);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.deepPurple),
      label: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 102, 102, 102)),),
      backgroundColor: Colors.deepPurple.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (FirebaseAuth.instance.currentUser == null) {
          showSignInModal(context);
        } else {
          pr('header pressed');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AgentProfileScreen(agentId: widget.post.userId),
            ),
          );
        }
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: widget.post.userProfileImageUrl.isNotEmpty
                ? CachedNetworkImageProvider(widget.post.userProfileImageUrl)
                : null,
            child: widget.post.userProfileImageUrl.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                timeago.format(widget.post.timestamp.toDate()),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: _sharePost,
        ),
        GestureDetector(
          onTap: () {
            if (FirebaseAuth.instance.currentUser == null) {
              showSignInModal(context);
              return;
            }
            // Use the callback from the widget's properties
            widget.onToggleLike(widget.post.id);
          },
          child: SizedBox(
            width: 30,
            height: 30,
            child: _riveArtboard == null
                ? const Center(child: Icon(Icons.favorite_border))
                : Rive(
                    artboard: _riveArtboard!,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: () {
            if (FirebaseAuth.instance.currentUser == null) {
              showSignInModal(context);
            } else {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CommentBottomSheet(postId: widget.post.id),
              );
            }
          },
        ),
        IconButton(
          icon: Icon(
            widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: widget.post.isSaved ? Theme.of(context).primaryColor : null,
          ),
          onPressed: () {
            if (FirebaseAuth.instance.currentUser == null) {
              showSignInModal(context);
            } else {
              // Use the callback from the widget's properties
              widget.onToggleSave(widget.post.id);
            }
          },
        ),
      ],
    );
  }
}