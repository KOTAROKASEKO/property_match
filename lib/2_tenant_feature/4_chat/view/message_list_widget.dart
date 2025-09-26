// lib/features/4_chat/view/message_list_widget.dart

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/message_model.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/audio_player_widget.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/full_screen_image_view.dart';
import 'package:re_conver/2_tenant_feature/4_chat/viewmodel/messageList.dart';
import 'package:re_conver/authentication/userdata.dart';

class MessageListView extends StatefulWidget {
  final String otherUserName;
  final String? otherUserPhotoUrl;
  const MessageListView({
    super.key,
    required this.otherUserName,
    this.otherUserPhotoUrl,
  });

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);

  @override
  void initState() {
    super.initState();
    final provider = context.read<MessageListProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        provider.loadMoreMessages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showMessageOptions(BuildContext context, MessageModel message, bool isMe) {
    final provider = context.read<MessageListProvider>();

    if (message.status == 'deleted_for_everyone') return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Wrap(
              children: <Widget>[
                if (message.messageType == 'text')
                  ListTile(
                    leading: const Icon(Icons.copy_rounded, color: Colors.deepPurple),
                    title: const Text('Copy Text'),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message.messageText ?? ''));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                if (isMe)
                  ListTile(
                    leading: Icon(Icons.delete_forever_rounded, color: Colors.red.shade700),
                    title: Text('Delete for everyone', style: TextStyle(color: Colors.red.shade700)),
                    onTap: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Delete Message'),
                            content: const Text('Delete this message for everyone? This cannot be undone.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Delete', style: TextStyle(color: Colors.red.shade700)),
                                onPressed: () {
                                  provider.deleteMessageForEveryone(message);
                                  Navigator.of(dialogContext).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessageListProvider>();

    if (provider.shouldScrollToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        provider.didScrollToBottom();
      });
    }

    return ListView.builder(
      key: const PageStorageKey('messageListView'),
      reverse: true,
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount:
          provider.displayItems.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (provider.isLoadingMore && index == provider.displayItems.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item =
            provider.displayItems[provider.displayItems.length - 1 - index];

        if (item is DateTime) {
          return _buildDateSeparator(item);
        } else if (item is MessageModel) {
          return _buildMessageItem(
            context,
            item,
            widget.otherUserName,
            widget.otherUserPhotoUrl,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Center(
      key: ValueKey("date_${date.toIso8601String()}"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blueGrey[50]?.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          DateFormat.yMMMd().format(date),
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    MessageModel message,
    String otherUserName,
    String? otherUserPhotoUrl,
  ) {
    final provider = context.read<MessageListProvider>();
    final bool isMe = message.isOutgoing;
    final color =
        isMe
            ? (Colors.deepPurple[400] ?? Colors.deepPurple)
            : (Colors.grey[300] ?? Colors.grey);
    final textColor = isMe ? Colors.white : Colors.black87;

    Widget messageContent;
    if (message.status == 'deleted_for_everyone') {
      messageContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.not_interested, color: textColor.withOpacity(0.8), size: 16),
          const SizedBox(width: 8),
          Text(
            'This message was deleted',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      );
    } else if (message.messageType == 'image') {
      messageContent = GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FullScreenImageView(
                imageUrl: message.remoteUrl!,
                localPath: message.localPath,
              ),
            ),
          );
        },
        child: Hero(
          tag: message.remoteUrl!,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: (message.localPath != null &&
                    File(message.localPath!).existsSync())
                ? Image.file(File(message.localPath!))
                : (message.remoteUrl != null)
                    ? CachedNetworkImage(
                        imageUrl: message.remoteUrl!,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image_not_supported),
                      )
                    : const Icon(Icons.image_not_supported),
          ),
        ),
      );
    } else if (message.messageType == 'audio') {
      messageContent = AudioMessagePlayer(
        key: ValueKey(message.messageId),
        message: message,
      );
    } else {
      messageContent = Text(
        message.messageText ?? '',
        style: TextStyle(color: textColor, fontSize: 16),
      );
    }

    final messageBubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.repliedToMessageText != null)
            _buildRepliedMessageContent(message, otherUserName),
          Card(
            elevation: 1,
            color: color,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: messageContent,
            ),
          ),
        ],
      ),
    );

    return Dismissible(
      key: ValueKey('dismiss_${message.messageId}'),
      direction: message.status != 'deleted_for_everyone'
          ? DismissDirection.startToEnd
          : DismissDirection.none,
      resizeDuration: null,
      confirmDismiss: (direction) async {
        provider.setReplyingTo(message);
        return false;
      },
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        alignment: Alignment.centerLeft,
        child: const Icon(
          Icons.reply,
          color: Colors.grey,
        ),
      ),
      child: GestureDetector(
        onLongPress: () {
          _showMessageOptions(context, message, isMe);
        },
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe && otherUserPhotoUrl != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      otherUserPhotoUrl,
                    ),
                  ),
                ),
              if (isMe && message.status != 'deleted_for_everyone')
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    DateFormat.jm().format(message.timestamp),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ),
              messageBubble,
              if (!isMe && message.status != 'deleted_for_everyone')
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    DateFormat.jm().format(message.timestamp),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepliedMessageContent(
    MessageModel message,
    String otherUserName,
  ) {
    final bool isReplyingToMe = message.repliedToWhoSent == userData.userId;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: const Border(
          left: BorderSide(color: Colors.deepPurple, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isReplyingToMe ? "You" : otherUserName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.repliedToMessageText ?? '[Unsupported message]',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}