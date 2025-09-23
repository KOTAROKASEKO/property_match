// lib/2_tenant_feature/4_chat/view/viewing_details_bottomsheet.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ViewingDetailsBottomSheet extends StatelessWidget {
  final String note;
  final List<String> imageUrls;

  const ViewingDetailsBottomSheet({
    super.key,
    required this.note,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24.0),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (imageUrls.isNotEmpty) ...[
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageUrls.length,
                    itemBuilder: (ctx, idx) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: imageUrls[idx],
                          width: 150,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (note.isNotEmpty)
                Text(
                  "Note:",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 8),
              Text(
                note,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}