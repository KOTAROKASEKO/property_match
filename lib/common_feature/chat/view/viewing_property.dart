// Widget for the "Viewing" tab
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:re_conver/common_feature/chat/model/chat_thread.dart';
import 'package:re_conver/common_feature/chat/view/chatThreadScreen.dart';
import 'package:re_conver/common_feature/chat/view/providerIndividualChat.dart';
import 'package:re_conver/common_feature/chat/view/viewing_details_bottomsheet.dart';
import 'package:re_conver/features/authentication/userdata.dart';

class ViewingAppointmentList extends StatelessWidget {
  final List<ViewingAppointment> appointments;
  final String Function(ChatThread) getOtherParticipantId;
  final Function(ViewingAppointment) onLongPress;

  const ViewingAppointmentList({
    required this.appointments,
    required this.getOtherParticipantId,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const Center(child: Text("No viewings scheduled."));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final thread = appointment.thread;
        final otherParticipantId =
            getOtherParticipantId(thread);

        if (thread.hisName == null) {
          return const SizedBox.shrink(); // Or a shimmer
        }

        final displayName = thread.hisName ?? 'Chat User';
        final imageUrl = thread.hisPhotoUrl;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                child: Text(
                  DateFormat('MMMM d, yyyy • h:mm a~')
                      .format(appointment.viewingTime),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Card(
                key: ValueKey(
                    '${thread.id}_${appointment.viewingTime.toIso8601String()}'),
                margin: EdgeInsets.zero,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              (imageUrl != null && imageUrl.isNotEmpty)
                                  ? CachedNetworkImageProvider(imageUrl)
                                  : null,
                          child: (imageUrl == null || imageUrl.isEmpty)
                              ? Text(displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : '?')
                              : null,
                        ),
                        title: Text(displayName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            DateFormat.jm().format(appointment.viewingTime)),
                        onTap: () {
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
                        },
                        onLongPress: () => onLongPress(appointment),
                      ),
                      if (appointment.imageUrls.isNotEmpty ||
                          (appointment.note != null &&
                              appointment.note!.isNotEmpty))
                        const Divider(height: 24),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => ViewingDetailsBottomSheet(
                              note: appointment.note ?? "",
                              imageUrls: appointment.imageUrls,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (appointment.imageUrls.isNotEmpty)
                              SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: appointment.imageUrls.length,
                                  itemBuilder: (ctx, idx) => Padding(
                                    padding:
                                        const EdgeInsets.only(right: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: appointment.imageUrls[idx],
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (appointment.note != null &&
                                appointment.note!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  "Note: ${appointment.note!}",
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
            ],
          ),
        );
      },
    );
  }
}
