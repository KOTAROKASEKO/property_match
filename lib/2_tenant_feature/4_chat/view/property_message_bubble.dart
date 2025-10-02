// lib/2_tenant_feature/4_chat/view/property_message_bubble.dart

import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/message_model.dart';

class PropertyMessageBubble extends StatelessWidget {
  final MessageModel message;
  const PropertyMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.messageText == null) {
      return const SizedBox.shrink();
    }

    final Map<String, dynamic> data = jsonDecode(message.messageText!);
    final List<String> photoUrls = List<String>.from(data['photoUrls'] ?? []);
    final bool isMe = message.isOutgoing;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.deepPurple[400] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            if (photoUrls.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                  ),
                  items: photoUrls.map((item) {
                    return Image.network(
                      item,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    );
                  }).toList(),
                ),
              ),

            // Property Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'No Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.attach_money,
                    'RM ${data['rent']?.toStringAsFixed(0) ?? 'N/A'} / month',
                    isMe,
                  ),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    data['location'] ?? 'No Location',
                    isMe,
                  ),
                  _buildDetailRow(
                    Icons.king_bed_outlined,
                    '${data['roomType'] ?? 'N/A'} Room',
                    isMe,
                  ),
                  _buildDetailRow(
                    Icons.people_alt_outlined,
                    '${data['gender'] ?? 'N/A'} Unit',
                    isMe,
                  ),
                  if (data['description'] != null &&
                      data['description'].isNotEmpty) ...[
                    const Divider(height: 20),
                    Text(
                      data['description'],
                      style: TextStyle(
                        color: isMe ? Colors.white.withOpacity(0.9) : Colors.black87,
                      ),
                    ),
                  ],

                  // Timestamp
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      DateFormat.jm().format(message.timestamp),
                      style: TextStyle(
                        color: isMe
                            ? Colors.white.withOpacity(0.8)
                            : Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isMe) {
    final color = isMe ? Colors.white.withOpacity(0.9) : Colors.black87;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}