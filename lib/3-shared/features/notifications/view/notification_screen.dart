import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../model/notification_model.dart';
import '../viewmodel/notification_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

// ★ Import MyProfilePage and AgentPostDetailScreen
import '../../1_agent_feature/1_profile/view/agent_post_detail_screen.dart';
import '../../1_agent_feature/1_profile/view/agent_profile_view.dart';

String pref_name = 'notification_permission_requested';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // 画面が開かれたときにすべての通知を既読にする
    context.read<NotificationViewModel>().markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: viewModel.notificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          final notifications = snapshot.data!.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationTile(notification: notification);
            },
          );
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    // ★★★ 修正: 通知タイプに応じたメッセージと遷移先の分岐 ★★★
    String message;
    IconData? iconData;

    if (notification.type == 'like') {
      message = '${notification.actorName} liked your post.';
    } else if (notification.type == 'comment') {
      message = '${notification.actorName} commented on your post.';
    } else if (notification.type == 'reservation') {
      message = '${notification.actorName} booked a viewing slot.'; 
      iconData = Icons.event_available;
    } else if (notification.type == 'reservation_cancel') {
      message = 'Reservation was cancelled.';
      iconData = Icons.event_busy;
    } else {
      message = 'You have a new notification.';
    }

    return ListTile(
      tileColor: notification.isRead ? Colors.transparent : Colors.deepPurple.withOpacity(0.05),
      leading: CircleAvatar(
        backgroundImage: notification.actorImageUrl.isNotEmpty
            ? CachedNetworkImageProvider(notification.actorImageUrl)
            : null,
        child: notification.actorImageUrl.isEmpty
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(message),
      subtitle: Text(timeago.format(notification.timestamp.toDate())),
      // 物件画像がある場合は画像、なければアイコンを表示
      trailing: notification.postSnippet.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: notification.postSnippet,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                // エラー時や画像のURLが空の場合はアイコンを表示
                errorWidget: (context, url, error) => Icon(iconData ?? Icons.image, color: Colors.grey),
                placeholder: (context, url) => Container(color: Colors.grey[200]),
              ),
            )
          : (iconData != null ? Icon(iconData, color: Colors.deepPurple) : null),
      onTap: () {
        // ★★★ 修正: 予約関連の場合はプロフィール画面へ遷移 ★★★
        if (notification.type == 'reservation' || notification.type == 'reservation_cancel') {
           // 予約管理は MyProfilePage にあるため、そこへ遷移
           Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MyProfilePage(),
            ),
          );
        } else if (notification.postId.isNotEmpty) {
           // いいね/コメントの場合は投稿詳細へ
           Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AgentPostDetailScreen(postId: notification.postId),
            ),
          );
        }
      },
    );
  }
}

Future<void> checkAndRequestNotificationPermission(BuildContext context) async {

  final status = await Permission.notification.status;
  if (status.isGranted) {
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(pref_name) ?? false) {
    return;
  }

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enable Notifications?'),
      content: const Text('Get notified about new messages and important updates.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Enable'),
        ),
      ],
    ),
  );

  await prefs.setBool(pref_name, true);

  if (result == true) {
    await Permission.notification.request();
  }
}