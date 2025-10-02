// lib/2_tenant_feature/4_chat/view/chatThreadScreen.dart

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/chat_thread.dart';
import 'package:re_conver/2_tenant_feature/4_chat/repo/isar_helper.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/add_edit_general_note_screen.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/add_edit_viewing_note_screen.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/chat_rooms/all_property.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/chat_rooms/viewing_property.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/date_time_picker_modal.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/report_user_dialogue.dart';
import 'package:re_conver/2_tenant_feature/4_chat/viewmodel/chat_service.dart';
import 'package:re_conver/authentication/userdata.dart';
import 'package:re_conver/service/local_notification.dart';


class ViewingAppointment {
  final ChatThread thread;
  final DateTime viewingTime;
  final String? note;
  final List<String> imageUrls;
  final int viewingIndex;

  ViewingAppointment({
    required this.thread,
    required this.viewingTime,
    this.note,
    this.imageUrls = const [],
    required this.viewingIndex,
  });
}

class ChatThreadsScreen extends StatefulWidget {
  final ValueChanged<ChatThread>? onThreadSelected;
  const ChatThreadsScreen({super.key, this.onThreadSelected});

  @override
  State<ChatThreadsScreen> createState() => _ChatThreadsScreenState();
}

class _ChatThreadsScreenState extends State<ChatThreadsScreen>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IsarService _isarService = IsarService();
  final ChatService _chatService = ChatService();
  
  late final TabController _tabController;
  StreamSubscription? _threadsSubscription; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeAndListenToThreads(); 
  }

  @override
  void dispose() {
    _threadsSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

   Future<void> _confirmDeleteChat(BuildContext context, ChatThread thread) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Chat?'),
        content: const Text(
            'This will permanently delete all messages in this conversation. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _chatService.deleteChat(thread.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat deleted successfully.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete chat: $e')),
          );
        }
      }
    }
  }




  void _initializeAndListenToThreads() {
    _threadsSubscription = _firestore
        .collection('chats')
        .where(Filter.or(
          Filter('whoSent', isEqualTo: userData.userId),
          Filter('whoReceived', isEqualTo: userData.userId),
        ))
        .snapshots()
        .listen((snapshot) async {
      if (!mounted) return;

      for (var change in snapshot.docChanges) {
        if (!change.doc.exists || change.doc.data() == null) continue;

        final thread = ChatThread.fromFirestore(
          change.doc,
        );

        final otherUserId = _getOtherParticipantId(thread, userData.userId);
        final userDoc = await _firestore.collection('users_prof').doc(otherUserId).get();
        if (userDoc.exists && userDoc.data() != null) {
          thread.hisName = userDoc.data()!['displayName'];
          thread.hisPhotoUrl = userDoc.data()!['profileImageUrl'];
        }
        await _isarService.saveChatThread(thread);
      }
    }, onError: (error) {
      print("Error listening to chat threads: $error");
    });
  }
  
  String _getOtherParticipantId(ChatThread thread, String currentUserId) {
    return thread.whoReceived != currentUserId
        ? thread.whoReceived
        : thread.whoSent;
  }
  void _showReportUserDialog(String reportedUserId) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const ReportUserDialog(),
    );

    if (reason != null && reason.isNotEmpty && mounted) {
      try {
        await _chatService.reportUser(
            reportedUserId: reportedUserId, reason: reason);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User reported.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to report user.')),
        );
      }
    }
  }

  void _showChatOptions(BuildContext context, ChatThread thread,
      ViewingAppointment? appointment) {
    final displayName = thread.hisName ?? 'Chat User';
    final photoUrl = thread.hisPhotoUrl;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? CachedNetworkImageProvider(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? Text(displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?')
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(displayName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (appointment != null)
                    ..._buildViewingOptions(ctx, appointment)
                  else
                    ..._buildAllOptions(ctx, thread),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAllOptions(BuildContext ctx, ChatThread thread) {
    final otherUserId = _getOtherParticipantId(thread, userData.userId);
    return [
      ListTile(
        leading: const Icon(Icons.note_add_outlined),
        title: const Text('Add/Edit Note & Photos'),
        onTap: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditGeneralNoteScreen(
                thread: thread,
              ),
            ),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.add_circle_outline),
        title: const Text('Add to Viewing'),
        onTap: () async {
          Navigator.of(ctx).pop();
          final DateTime? selectedDateTime =
              await showModalBottomSheet<DateTime>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const DateTimePickerModal(),
          );
          if (selectedDateTime != null) {
            _addViewingTime(thread, selectedDateTime);
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.flag_outlined),
        title: const Text('Report User'),
        onTap: () {
          Navigator.of(ctx).pop();
          _showReportUserDialog(otherUserId);
        },
      ),
      ListTile(
        leading: const Icon(Icons.block),
        title: const Text('Block User'),
        onTap: () {
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
                content: Text('Block user functionality not implemented yet.')),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.delete_forever_outlined, color: Colors.red[700]),
        title: Text('Delete Chat', style: TextStyle(color: Colors.red[700])),
        onTap: () {
          Navigator.of(ctx).pop(); // Close the bottom sheet
          _confirmDeleteChat(context, thread);
        },
      ),
    ];
  }

  List<Widget> _buildViewingOptions(
      BuildContext ctx, ViewingAppointment appointment) {
    final otherUserId =
        _getOtherParticipantId(appointment.thread, userData.userId);
    return [
      ListTile(
        leading: const Icon(Icons.note_add_outlined),
        title: const Text('Add/Edit Note & Photos'),
        onTap: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditViewingNoteScreen(
                thread: appointment.thread,
                viewingIndex: appointment.viewingIndex,
              ),
            ),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.edit_calendar_outlined),
        title: const Text('Change Time'),
        onTap: () async {
          Navigator.of(ctx).pop();
          final DateTime? selectedDateTime =
              await showModalBottomSheet<DateTime>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const DateTimePickerModal(),
          );
          if (selectedDateTime != null) {
            _changeViewingTime(
                appointment.thread, appointment.viewingTime, selectedDateTime);
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.delete_outline),
        title: const Text('Delete from Viewing'),
        onTap: () {
          Navigator.of(ctx).pop();
          _removeViewingTime(appointment.thread, appointment.viewingTime);
        },
      ),
      ListTile(
        leading: Icon(Icons.delete_forever_outlined, color: Colors.red[700]),
        title: Text('Delete Chat', style: TextStyle(color: Colors.red[700])),
        onTap: () {
          Navigator.of(ctx).pop(); // Close the bottom sheet
          _confirmDeleteChat(context, appointment.thread);
        },
      ),
      ListTile(
        leading: const Icon(Icons.flag_outlined),
        title: const Text('Report user'),
        onTap: () {
          Navigator.of(ctx).pop();
          _showReportUserDialog(otherUserId);
        },
      ),
    ];
  }

  Future<void> _addViewingTime(ChatThread thread, DateTime newTime) async {
     final notificationService = NotificationService();
    var status = await Permission.notification.status;
    if (status.isDenied) {
      final bool granted = await notificationService.requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('通知を送信するには許可が必要です。')),
          );
        }
        return; // 許可されなければここで処理を中断
      }
    }
    try {
      await _firestore.collection('chats').doc(thread.id).update({
        'viewingTimes': FieldValue.arrayUnion([Timestamp.fromDate(newTime)]),
        'viewingNotes': FieldValue.arrayUnion(['']),
        'viewingImageUrls': FieldValue.arrayUnion([jsonEncode([])]),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding viewing time: $e')),
        );
      }
    }
  }

  Future<void> _removeViewingTime(
      ChatThread thread, DateTime timeToRemove) async {
    final docRef = _firestore.collection('chats').doc(thread.id);
    try {
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) return;

        final data = doc.data()!;
        final currentTimes = List<Timestamp>.from(data['viewingTimes'] ?? []);
        final currentNotes = List<String>.from(data['viewingNotes'] ?? []);
        final currentImageUrls =
            List<dynamic>.from(data['viewingImageUrls'] ?? []);
        final index =
            currentTimes.indexWhere((t) => t.toDate() == timeToRemove);

        if (index != -1) {
          currentTimes.removeAt(index);
          if (index < currentNotes.length) {
            currentNotes.removeAt(index);
          }
          if (index < currentImageUrls.length) {
            currentImageUrls.removeAt(index);
          }
          transaction.update(docRef, {
            'viewingTimes': currentTimes,
            'viewingNotes': currentNotes,
            'viewingImageUrls': currentImageUrls
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing viewing time: $e')),
        );
      }
    }
  }

  Future<void> _changeViewingTime(
      ChatThread thread, DateTime oldTime, DateTime newTime) async {
    final docRef = _firestore.collection('chats').doc(thread.id);
    try {
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) return;

        final currentTimes =
            List<Timestamp>.from(doc.data()?['viewingTimes'] ?? []);
        final index = currentTimes.indexWhere((t) => t.toDate() == oldTime);

        if (index != -1) {
          currentTimes[index] = Timestamp.fromDate(newTime);
          transaction.update(docRef, {'viewingTimes': currentTimes});
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error changing viewing time: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (userData.userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Chats')),
        body: const Center(child: Text("Please log in to see your chats.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chats', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Viewing'),
          ],
        ),
      ),
      body: StreamBuilder<List<ChatThread>>(
        stream: _isarService.watchChatThreads(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text("No chats yet."));
          }

          final allThreads = snapshot.data!;
          allThreads.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

          final viewingAppointments = allThreads.expand<ViewingAppointment>((thread) {
            return thread.viewingTimes.asMap().entries.map((entry) {
              int index = entry.key;
              DateTime time = entry.value;
              String? note = (index < thread.viewingNotes.length) ? thread.viewingNotes[index] : null;
              List<String> imageUrls = [];
              if (index < thread.viewingImageUrls.length && thread.viewingImageUrls[index].isNotEmpty) {
                try {
                  var decoded = jsonDecode(thread.viewingImageUrls[index]);
                  if (decoded is String) {
                    decoded = jsonDecode(decoded);
                  }
                  if (decoded is List) {
                    imageUrls = List<String>.from(decoded);
                  }
                } catch (e) {
                  print("Error decoding image urls: $e");
                }
              }
              return ViewingAppointment(
                thread: thread,
                viewingTime: time,
                note: note,
                imageUrls: imageUrls,
                viewingIndex: index,
              );
            });
          }).toList();

          viewingAppointments.sort((a, b) => a.viewingTime.compareTo(b.viewingTime));

          return TabBarView(
            controller: _tabController,
            children: [
              ChatThreadList(
                threads: allThreads,
                getOtherParticipantId: _getOtherParticipantId,
                onLongPress: (thread) => _showChatOptions(context, thread, null),
                onThreadSelected: widget.onThreadSelected,
              ),
              ViewingAppointmentList(
                appointments: viewingAppointments,
                getOtherParticipantId: _getOtherParticipantId,
                onLongPress: (appointment) => _showChatOptions(context, appointment.thread, appointment),
              ),
            ],
          );
        },
      ),
    );
  }
}