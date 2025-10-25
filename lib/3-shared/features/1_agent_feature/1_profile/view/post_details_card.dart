import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/model/PostModel.dart';
import '../../../2_tenant_feature/1_discover/view/comment_bottomsheet.dart';

class PostDetailsCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PostDetailsCard({
    super.key,
    required this.post,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<PostDetailsCard> createState() => _PostDetailsCardState();
}

class _PostDetailsCardState extends State<PostDetailsCard> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post.imageUrls.isNotEmpty) _buildImageCarousel(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.condominiumName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'RM ${widget.post.rent.toStringAsFixed(0)} / month',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
                const SizedBox(height: 12),
                _buildInfoChips(),
                const SizedBox(height: 12),
                Text(
                  widget.post.description,
                  style: TextStyle(color: Colors.grey[700], height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Posted ${timeago.format(widget.post.timestamp.toDate())}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          // --- 操作ボタン ---
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: widget.onEdit,
                      tooltip: 'Edit Post',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(context),
                      tooltip: 'Delete Post',
                    ),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.comment_outlined),
                  label: const Text('View Comments'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => CommentBottomSheet(postId: widget.post.id),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 画像カルーセル用のウィジェット ---
  Widget _buildImageCarousel() {
    return Stack(
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
          items: widget.post.imageUrls.map((item) {
            return CachedNetworkImage(
              imageUrl: item,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
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
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  // --- 詳細情報をチップで表示するウィジェット ---
  Widget _buildInfoChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        _buildInfoChip(Icons.location_on_outlined, widget.post.location),
        _buildInfoChip(Icons.king_bed_outlined, widget.post.roomType),
        _buildInfoChip(Icons.people_alt_outlined, '${widget.post.gender} Unit'),
      ],
    );
  }
  
  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.deepPurple),
      label: Text(label),
      backgroundColor: Colors.deepPurple.withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post? This will also remove its associated chat template.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onDelete();
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}