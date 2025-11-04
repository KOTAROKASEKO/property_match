import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_data/shared_data.dart';
import 'providerIndividualChat.dart';
import 'viewing_details_bottomsheet.dart';

class ChatThreadList extends StatelessWidget {
  final List<ChatThread> threads;
  final String Function(ChatThread) getOtherParticipantId;
  final Function(ChatThread) onLongPress;
  final ValueChanged<ChatThread>? onThreadSelected;

  const ChatThreadList({
    super.key,
    required this.threads,
    required this.getOtherParticipantId,
    required this.onLongPress,
    this.onThreadSelected,
  });


  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      return const Center(child: Text("No chats yet."));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0),
      itemCount: threads.length,
      itemBuilder: (context, index) {
        final thread = threads[index];
        final otherParticipantId =
            getOtherParticipantId(thread);


        final displayName = thread.hisName ?? 'Chat User';
        final imageUrl = thread.hisPhotoUrl;
        final unreadCount = thread.unreadCountMap[userData.userId] ?? 0;
        final note = thread.generalNote;

        // ★ Use the safe decoding helper for generalImageUrls
        // Assuming generalImageUrls from Isar/Drift is List<String>
        // If Firestore stores it differently, adjust accordingly
        List<String> generalImageUrlsDecoded = thread.generalImageUrls; // Directly use if it's List<String>
        // If thread.generalImageUrls might be dynamic/String from Firestore sync:
        // List<String> generalImageUrlsDecoded = _decodeImageUrls(thread.generalImageUrls);


        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Card(
            key: ValueKey(thread.id),
            elevation: 2.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                          ? CachedNetworkImageProvider(imageUrl)
                          : null,
                      child: (imageUrl == null || imageUrl.isEmpty)
                          ? Text(displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : '?')
                          : null,
                    ),
                    title: Text(displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(thread.lastMessage ?? '',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(DateFormat.yMd().format(thread.timeStamp),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle),
                            child: Text(unreadCount.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          )
                        else const SizedBox(height: 24),
                      ],
                    ),
                    onTap: () {
                      if (onThreadSelected != null) {
                        onThreadSelected!(thread);
                      } else {
                        print('thread id is ::::  ${thread.id}');
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    IndividualChatScreenWithProvider(
                              chatThreadId: thread.id,
                              otherUserUid: otherParticipantId,
                              otherUserName: displayName,
                              otherUserPhotoUrl: imageUrl,
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;
                              final tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      }
                    },
                    onLongPress: () => onLongPress(thread),
                  ),
                  if (generalImageUrlsDecoded.isNotEmpty || (note != null && note.isNotEmpty))
                    const Divider(height: 24),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ViewingDetailsBottomSheet(
                          note: note ?? "",
                          imageUrls: generalImageUrlsDecoded, // Use decoded URLs
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (generalImageUrlsDecoded.isNotEmpty)
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: generalImageUrlsDecoded.length,
                              itemBuilder: (ctx, idx) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: generalImageUrlsDecoded[idx], // Use decoded URLs
                                    width: 80,
                                    fit: BoxFit.cover,
                                     placeholder: (context, url) => Container(color: Colors.grey[200]),
                                     errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (note != null && note.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              "Note: $note",
                              style:
                                  TextStyle(color: Colors.grey.shade700),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}