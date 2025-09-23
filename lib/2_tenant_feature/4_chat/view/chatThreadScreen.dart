// lib/2_tenant_feature/4_chat/view/chatThreadScreen.dart

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/chat_thread.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/user_profile.dart';
import 'package:re_conver/2_tenant_feature/4_chat/repo/isar_helper.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/add_edit_viewing_note_screen.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/date_time_picker_modal.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/providerIndividualChat.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/report_user_dialogue.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/viewing_details_bottomsheet.dart';
import 'package:re_conver/2_tenant_feature/4_chat/viewmodel/chat_service.dart';
import 'package:re_conver/authentication/userdata.dart';
import 'package:shimmer/shimmer.dart';

// Helper class to manage individual viewing appointments
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
  const ChatThreadsScreen({super.key});

  @override
  State<ChatThreadsScreen> createState() => _ChatThreadsScreenState();
}

class _ChatThreadsScreenState extends State<ChatThreadsScreen>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IsarService _isarService = IsarService();
  final ChatService _chatService = ChatService();
  final Map<String, UserProfileForChat> _userProfiles = {};

  late final TabController _tabController;
  bool _isDataInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeScreen();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    await _syncDataFromFirestoreToIsar();
    await _loadDataFromIsar();
  }

  Future<void> _loadDataFromIsar() async {
    if (!mounted) return;
    final threads = await _isarService.getAllChatThreads();
    final userIds = threads
        .map((thread) => _getOtherParticipantId(thread, userData.userId))
        .toSet();
    for (final userId in userIds) {
      if (userId.isNotEmpty) {
        final cachedProfile = await _isarService.getUserProfile(userId);
        if (cachedProfile != null) _userProfiles[userId] = cachedProfile;
      }
    }
    if (mounted) {
      setState(() {
        _isDataInitialized = true;
      });
    }
  }

  Future<void> _syncDataFromFirestoreToIsar() async {
    if (!mounted) return;
    final threadsSnapshot = await _firestore
        .collection('chats')
        .where(Filter.or(
          Filter('whoSent', isEqualTo: userData.userId),
          Filter('whoReceived', isEqualTo: userData.userId),
        ))
        .get();
    final threadsFromFirestore =
        threadsSnapshot.docs.map((doc) => ChatThread.fromFirestore(doc)).toList();
    for (final thread in threadsFromFirestore) {
      await _isarService.saveChatThread(thread);
    }
    final userIds = threadsFromFirestore
        .map((thread) => _getOtherParticipantId(thread, userData.userId))
        .toSet();
    for (final userId in userIds) {
      if (userId.isNotEmpty) {
        final doc = await _firestore.collection('users_prof').doc(userId).get();
        if (doc.exists) {
          final data = doc.data()!;
          final freshProfile = UserProfileForChat()
            ..userId = userId
            ..displayName = data['displayName']
            ..profileImageUrl = data['profileImageUrl']
            ..lastFetched = DateTime.now();
          await _isarService.saveUserProfile(freshProfile);
        }
      }
    }
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

  void _showChatOptions(
      BuildContext context, ChatThread thread, ViewingAppointment? appointment) {
    final otherUserId = _getOtherParticipantId(thread, userData.userId);
    final profile = _userProfiles[otherUserId];
    final displayName = profile?.displayName ?? 'Chat User';

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
                    backgroundImage: (profile?.profileImageUrl != null &&
                            profile!.profileImageUrl!.isNotEmpty)
                        ? CachedNetworkImageProvider(profile.profileImageUrl!)
                        : null,
                    child: (profile?.profileImageUrl == null ||
                            profile!.profileImageUrl!.isEmpty)
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

  Future<void> _removeViewingTime(ChatThread thread, DateTime timeToRemove) async {
    final docRef = _firestore.collection('chats').doc(thread.id);
    try {
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) return;

        final data = doc.data()!;
        final currentTimes = List<Timestamp>.from(data['viewingTimes'] ?? []);
        final currentNotes = List<String>.from(data['viewingNotes'] ?? []);
        final currentImageUrls = List<dynamic>.from(data['viewingImageUrls'] ?? []);
        final index = currentTimes.indexWhere((t) => t.toDate() == timeToRemove);

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

        final currentTimes = List<Timestamp>.from(doc.data()?['viewingTimes'] ?? []);
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
      body: !_isDataInitialized
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('chats')
                  .where(Filter.or(
                    Filter('whoSent', isEqualTo: userData.userId),
                    Filter('whoReceived', isEqualTo: userData.userId),
                  ))
                  .orderBy('timeStamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !_isDataInitialized) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No chats yet."));
                }

                final allThreads = snapshot.data!.docs
                    .map((doc) => ChatThread.fromFirestore(doc))
                    .toList();

                final viewingAppointments = allThreads.expand<ViewingAppointment>((thread) {
                  return thread.viewingTimes.asMap().entries.map((entry) {
                    int index = entry.key;
                    DateTime time = entry.value;
                    String? note = (index < thread.viewingNotes.length)
                        ? thread.viewingNotes[index]
                        : null;
                    List<String> imageUrls = [];
                    if (index < thread.viewingImageUrls.length &&
                        thread.viewingImageUrls[index].isNotEmpty) {
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

                viewingAppointments
                    .sort((a, b) => a.viewingTime.compareTo(b.viewingTime));

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _ChatThreadList(
                      threads: allThreads,
                      userProfiles: _userProfiles,
                      getOtherParticipantId: _getOtherParticipantId,
                      onLongPress: (thread) =>
                          _showChatOptions(context, thread, null),
                    ),
                    _ViewingAppointmentList(
                      appointments: viewingAppointments,
                      userProfiles: _userProfiles,
                      getOtherParticipantId: _getOtherParticipantId,
                      onLongPress: (appointment) => _showChatOptions(
                          context, appointment.thread, appointment),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

// Widget for the "All" tab
class _ChatThreadList extends StatelessWidget {
  final List<ChatThread> threads;
  final Map<String, UserProfileForChat> userProfiles;
  final String Function(ChatThread, String) getOtherParticipantId;
  final Function(ChatThread) onLongPress;

  const _ChatThreadList({
    required this.threads,
    required this.userProfiles,
    required this.getOtherParticipantId,
    required this.onLongPress,
  });

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (dateTime.isAfter(today)) return DateFormat.jm().format(dateTime);
    return DateFormat.yMd().format(dateTime);
  }

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
        final otherParticipantId = getOtherParticipantId(thread, userData.userId);
        final profile = userProfiles[otherParticipantId];

        if (profile == null) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: const ListTile(
              leading: CircleAvatar(backgroundColor: Colors.white),
              title: SizedBox(
                  height: 16, width: 100, child: ColoredBox(color: Colors.white)),
              subtitle: SizedBox(
                  height: 12, width: 150, child: ColoredBox(color: Colors.white)),
            ),
          );
        }

        final displayName = profile.displayName ?? 'Chat User';
        final imageUrl = profile.profileImageUrl;
        final unreadCount = thread.unreadCountMap[userData.userId] ?? 0;

        return Card(
          key: ValueKey(thread.id),
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          elevation: 1.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                  ? CachedNetworkImageProvider(imageUrl)
                  : null,
              child: (imageUrl == null || imageUrl.isEmpty)
                  ? Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?')
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
                Text(_formatTimestamp(thread.timeStamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                        color: Colors.deepPurple, shape: BoxShape.circle),
                    child: Text(unreadCount.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  )
                else
                  const SizedBox(height: 24),
              ],
            ),
            onTap: () {
                Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                  IndividualChatScreenWithProvider(
                    chatThreadId: thread.id,
                    otherUserUid: otherParticipantId,
                    otherUserName: displayName,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;
                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                  },
                ),
                );
            },
            onLongPress: () => onLongPress(thread),
          ),
        );
      },
    );
  }
}

// Widget for the "Viewing" tab
class _ViewingAppointmentList extends StatelessWidget {
  final List<ViewingAppointment> appointments;
  final Map<String, UserProfileForChat> userProfiles;
  final String Function(ChatThread, String) getOtherParticipantId;
  final Function(ViewingAppointment) onLongPress;

  const _ViewingAppointmentList({
    required this.appointments,
    required this.userProfiles,
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
        final otherParticipantId = getOtherParticipantId(thread, userData.userId);
        final profile = userProfiles[otherParticipantId];

        if (profile == null) {
          return const SizedBox.shrink(); // Or a shimmer
        }

        final displayName = profile.displayName ?? 'Chat User';
        final imageUrl = profile.profileImageUrl;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                child: Text(
                  DateFormat('MMMM d, yyyy • h:mm a~').format(appointment.viewingTime),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Card(
                key: ValueKey('${thread.id}_${appointment.viewingTime.toIso8601String()}'),
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
                          backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                              ? CachedNetworkImageProvider(imageUrl)
                              : null,
                          child: (imageUrl == null || imageUrl.isEmpty)
                              ? Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?')
                              : null,
                        ),
                        title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat.jm().format(appointment.viewingTime)),
                        onTap: () {
                            Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                IndividualChatScreenWithProvider(
                                chatThreadId: thread.id,
                                otherUserUid: otherParticipantId,
                                otherUserName: displayName,
                                ),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;
                              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
                      if (appointment.imageUrls.isNotEmpty || (appointment.note != null && appointment.note!.isNotEmpty))
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
                                    padding: const EdgeInsets.only(right: 8.0),
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
                            if (appointment.note != null && appointment.note!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  "Note: ${appointment.note!}",
                                  style: TextStyle(color: Colors.grey.shade700),
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