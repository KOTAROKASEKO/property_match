// lib/3-shared/features/2_tenant_feature/1_discover/view/post_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:flutter/services.dart'; // Riveロード用だったため不要なら削除
import 'package:intl/intl.dart';
import 'package:shared_data/shared_data.dart';
import '../../../../core/model/PostModel.dart';
import 'agent_profile_screen.dart';
import 'comment_bottomsheet.dart';
import 'full_pic_screen.dart';
import '../../../authentication/auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart'; // ★ 追加

class PostCard extends StatefulWidget {
  final PostModel post;
  final Function(String) onToggleLike; // ★ UIからは削除しますが、呼び出し元のエラー回避のため残します
  final Function(String) onToggleSave;
  final Function(PostModel)? onStartChat;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onToggleLike,
    required this.onToggleSave,
    this.onStartChat,
    this.onTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentPage = 0;
  
  // ★ Rive関連の変数は削除しました
  // Artboard? _riveArtboard;
  // SMIInput<bool>? _isLikedInput;

  @override
  void initState() {
    super.initState();
    // ★ Riveのロード処理を削除しました
  }

  void _sharePost() {
    final post = widget.post;
    final String shareUrl = 'https://bilikmatch.com/app/#/listing/${post.id}';
    final String textToShare = 'Check out this listing on BilikMatch:\n\n'
        '🏠 *Property:* ${post.condominiumName}\n'
        '💰 *Rent:* RM ${post.rent.toStringAsFixed(0)}/month\n'
        '🚪 *Room Type:* ${post.roomType}\n'
        '📍 *Location:* ${post.location}\n\n'
        '$shareUrl\n\n'
        'View more in the app!';
    Share.share(textToShare, subject: 'Room for rent: ${post.condominiumName}');
  }

  // ★ WhatsApp起動ロジックを追加
  Future<void> _launchWhatsApp() async {
    // PostModelにphoneNumberが含まれている前提です
    final phone = widget.post.phoneNumber; 
    
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No WhatsApp number available for this agent.')),
      );
      return;
    }

    // 数字以外を除去
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    // WhatsAppのURLスキーム
    final url = Uri.parse('https://wa.me/$cleanPhone');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open WhatsApp: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // _isLikedInput?.value = widget.post.isLikedByCurrentUser; // ★ 削除

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
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
                  tag: item,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.onTap != null) {
                        widget.onTap!();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageView(
                              imageUrl: item,
                            ),
                          ),
                        );
                      }
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

  Widget _buildContent(BuildContext context) {
    final List<Widget> chips = [
      _buildInfoChip(Icons.meeting_room_outlined, widget.post.roomType),
      _buildInfoChip(Icons.person_outline, '${widget.post.gender} Unit'),
    ];

    if (widget.post.durationStart != null &&
        widget.post.durationMonths != null) {
      chips.add(_buildInfoChip(
        Icons.date_range_outlined,
        '${DateFormat.yMd().format(widget.post.durationStart!)} - ${widget.post.durationMonths!} months',
      ));
    }

    if (widget.post.hobbies.isNotEmpty) {
      chips.addAll(widget.post.hobbies
          .map((hobby) => _buildInfoChip(Icons.interests_outlined, hobby))
          .toList());
    }

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

          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              itemBuilder: (context, index) {
                return chips[index];
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 8.0);
              },
            ),
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
              Expanded(
                child: _buildUserHeader(context),
              ),
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
                  widget.onStartChat?.call(widget.post);
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  timeago.format(widget.post.timestamp.toDate()),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
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
        
        // ★★★ RiveのいいねボタンをWhatsAppボタンに置換 ★★★
        IconButton(
          icon: SvgPicture.asset(
            'whatsapp.svg', // ★ あなたのSVGファイルのパスに合わせてください
            width: 23,
            height: 23,
          ),
          tooltip: 'Contact on WhatsApp',
          onPressed: () {
            _launchWhatsApp();
          },
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
              widget.onToggleSave(widget.post.id);
            }
          },
        ),
      ],
    );
  }
}