// lib/2_tenant_feature/4_chat/view/property_message_bubble.dart

import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// 1. StatefulWidgetに変更
class PropertyMessageBubble extends StatefulWidget {
  final MessageModel message;
  const PropertyMessageBubble({super.key, required this.message});

  @override
  State<PropertyMessageBubble> createState() => _PropertyMessageBubbleState();
}

// 2. Stateクラスを作成
class _PropertyMessageBubbleState extends State<PropertyMessageBubble> {
  // 3. 説明文の展開状態を管理する変数
  bool _isExpanded = false;
  // 4. 「続きをみる」を表示する文字数のしきい値（お好みで調整してください）
  static const int _maxChars = 100;

  Future<void> _launchMaps(BuildContext context, String location) async {
    if (location.isEmpty || location == 'No Location') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location provided to open map.')),
      );
      return;
    }

    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $googleMapsUrl';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open map: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 5. Stateクラスから `widget.message` でアクセスするように変更
    if (widget.message.messageText == null) {
      return const SizedBox.shrink();
    }

    final Map<String, dynamic> data = jsonDecode(widget.message.messageText!);
    final List<String> photoUrls = List<String>.from(data['photoUrls'] ?? []);
    final bool isMe = widget.message.isOutgoing;
    final String location = data['location'] ?? 'No Location';

    // ▽▽▽ 説明文のロジック変更 ▽▽▽
    final String description = data['description'] ?? '';
    final bool isLongDescription = description.length > _maxChars;
    // △△△ 説明文のロジック変更 △△△

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
                  GestureDetector(
                    onTap: () => _launchMaps(context, location),
                    child: _buildDetailRow(
                      Icons.location_on_outlined,
                      location,
                      isMe,
                      trailing: Icon(
                        Icons.open_in_new,
                        color: isMe
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black54,
                        size: 18,
                      ),
                    ),
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

                  // ▽▽▽ 説明文の表示ロジック ▽▽▽
                  if (description.isNotEmpty) ...[
                    const Divider(height: 20),
                    Text(
                      description,
                      style: TextStyle(
                        color: isMe
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black87,
                      ),
                      // 6. maxLinesとoverflowを設定
                      maxLines: isLongDescription && !_isExpanded ? 3 : null,
                      overflow: isLongDescription && !_isExpanded
                          ? TextOverflow.ellipsis
                          : TextOverflow.visible,
                    ),
                    // 7. 長い説明文の場合のみ「続きをみる/隠す」ボタンを表示
                    if (isLongDescription)
                      GestureDetector(
                        onTap: () {
                          // 8. タップで状態を更新
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _isExpanded ? 'hide' : 'read all',
                            style: TextStyle(
                              color:
                                  isMe ? Colors.white : Colors.deepPurple[700],
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                  // △△△ 説明文の表示ロジック △△△

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      // 9. `widget.message` を使うように変更
                      DateFormat.jm().format(widget.message.timestamp),
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

  // 10. `_buildDetailRow` も Stateクラス内に移動
  Widget _buildDetailRow(IconData icon, String text, bool isMe,
      {Widget? trailing}) {
    final color = isMe ? Colors.white.withOpacity(0.9) : Colors.black87;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color))),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }
}