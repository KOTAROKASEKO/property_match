import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/post_model.dart';
import 'package:re_conver/2_tenant_feature/2_discover/view/comment_bottomsheet.dart';
import 'package:re_conver/2_tenant_feature/2_discover/viewmodel/discover_viewmodel.dart';
import 'package:re_conver/authentication/auth_service.dart';
import 'package:rive/rive.dart' hide Image; // Import the Rive package
import 'package:timeago/timeago.dart' as timeago;
import 'package:carousel_slider/carousel_slider.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final CarouselSliderController _carouselController = CarouselSliderController();
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
          var controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
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

 

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiscoverViewModel>();
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
          _buildContent(context, viewModel),
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
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(item),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Chip(
            backgroundColor: Colors.black54,
            label: Text(
              'RM ${widget.post.rent.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
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
                    color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, DiscoverViewModel viewModel) {
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
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(Icons.meeting_room_outlined, widget.post.roomType),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.person_outline, '${widget.post.gender} Unit'),
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
              _buildActionButtons(context, viewModel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.deepPurple),
      label: Text(label),
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
          // TODO: Navigate to Agent Profile Screen
        }
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: widget.post.userProfileImageUrl.isNotEmpty
                ? NetworkImage(widget.post.userProfileImageUrl)
                : null,
            child: widget.post.userProfileImageUrl.isEmpty ? const Icon(Icons.person) : null,
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

  Widget _buildActionButtons(BuildContext context, DiscoverViewModel viewModel) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (FirebaseAuth.instance.currentUser == null) {
              showSignInModal(context);
              return;
            }
            viewModel.toggleLike(widget.post.id);
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
              viewModel.savePost(widget.post.id);
            }
          },
        ),
      ],
    );
  }
}