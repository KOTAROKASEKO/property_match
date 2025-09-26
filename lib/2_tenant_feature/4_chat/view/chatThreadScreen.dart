// lib/2_tenant_feature/4_chat/view/chatThreadScreen.dart

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/chat_thread.dart';
import 'package:re_conver/2_tenant_feature/4_chat/repo/isar_helper.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/add_edit_general_note_screen.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/add_edit_viewing_note_screen.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/chat_rooms/all_property.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/chat_rooms/viewing_property.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/date_time_picker_modal.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/report_user_dialogue.dart';
import 'package:re_conver/2_tenant_feature/4_chat/viewmodel/chat_service.dart';
import 'package:re_conver/app/debug_print.dart';
import 'package:re_conver/authentication/userdata.dart';

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
    await _loadDataFromIsar();
    await _syncDataFromFirestoreToIsar();
  }

  Future<void> _loadDataFromIsar() async {
    if (!mounted) return;
    final threads = await _isarService.getAllChatThreads();
    if (threads.isNotEmpty && mounted) {
      setState(() {
        _isDataInitialized = true;
      });
    }else{
      pr('No chat threads found in Isar DB during initialization.');
    }
  }

  Future<void> _syncDataFromFirestoreToIsar() async {
  if (!mounted) return;

  try {
    final threadsSnapshot = await _firestore
        .collection('chats')
        .where(Filter.or(
          Filter('whoSent', isEqualTo: userData.userId),
          Filter('whoReceived', isEqualTo: userData.userId),
        ))
        .get();

    final threadsFromFirestore =
        threadsSnapshot.docs.map((doc) => ChatThread.fromFirestore(doc)).toList();

    // ユーザー情報をまとめて取得するための準備
    final userIdsToFetch = threadsFromFirestore
        .where((thread) => thread.hisName == null || thread.hisPhotoUrl == null)
        .map((thread) => _getOtherParticipantId(thread, userData.userId))
        .toSet() // 重複を削除
        .toList();

        for(String id in userIdsToFetch){
          pr('Need to fetch user profile for userId: $id');
        }

    final Map<String, Map<String, dynamic>> userProfiles = {};
    if (userIdsToFetch.isNotEmpty) {
      final userDocs = await Future.wait(userIdsToFetch
          .map((userId) => _firestore.collection('users_prof').doc(userId).get()));
      for (var userDoc in userDocs) {
        if (userDoc.exists) {
          pr('Fetched profile for the user ${userDoc.data()?["displayName"]}');
          userProfiles[userDoc.id] = userDoc.data()!;
        }
      }
    }

    for (final thread in threadsFromFirestore) {
      if (thread.hisName == null || thread.hisPhotoUrl == null) {
        final otherUserId = _getOtherParticipantId(thread, userData.userId);
        final userProfile = userProfiles[otherUserId];
        if (userProfile != null) {
          pr('display name : ${userProfile['displayName']}');
          thread.hisName = userProfile['displayName'];
          thread.hisPhotoUrl = userProfile['profileImageUrl'];
        }
      }
    }
    if (threadsFromFirestore.isNotEmpty) {

      pr('final check hisName field: ${threadsFromFirestore[0].hisName}');
      await _isarService.saveAllChatThreads(threadsFromFirestore);
    }
  } catch (e) {
    print("Error syncing data from Firestore to Isar: $e");
  } finally {
    // UIの初期化が完了したことを通知
    if (mounted && !_isDataInitialized) {
      setState(() {
        _isDataInitialized = true;
      });
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
      body: !_isDataInitialized
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<ChatThread>>(
              stream: _isarService.watchChatThreads(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !_isDataInitialized) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No chats yet."));
                }

                final allThreads = snapshot.data!;
                allThreads.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

                final viewingAppointments =
                    allThreads.expand<ViewingAppointment>((thread) {
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
                        var decoded =
                            jsonDecode(thread.viewingImageUrls[index]);
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
                    ChatThreadList(
                      threads: allThreads,
                      getOtherParticipantId: _getOtherParticipantId,
                      onLongPress: (thread) =>
                          _showChatOptions(context, thread, null),
                    ),
                    ViewingAppointmentList(
                      appointments: viewingAppointments,
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


