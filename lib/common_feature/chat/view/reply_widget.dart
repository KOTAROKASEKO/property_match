import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/authentication/userdata.dart';
import 'package:re_conver/common_feature/chat/viewmodel/messageList.dart';

class ReplyPreviewWidget extends StatelessWidget {
    final String otherUserName;
    const ReplyPreviewWidget({super.key, required this.otherUserName});
    
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessageListProvider>();
    final message = provider.replyingToMessage;
    if (message == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 40, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.whoSent == userData.userId ? "You" : otherUserName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                Text(
                  message.messageText ?? (message.messageType == 'image' ? '[Image]' : '[Voice Message]'),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => provider.setReplyingTo(null),
          ),
        ],
      ),
    );
  }
}


