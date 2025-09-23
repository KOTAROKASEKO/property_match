// lib/features/4_chat/view/providerIndividualChat.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/user_profile.dart';
import 'package:re_conver/2_tenant_feature/4_chat/repo/isar_helper.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/message_input_widget.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/message_list_widget.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/reply_widget.dart';
import 'package:re_conver/2_tenant_feature/4_chat/viewmodel/messageList.dart';

// --- Main Widget & Provider Setup ---

class IndividualChatScreenWithProvider extends StatelessWidget {
  final String chatThreadId;
  final String otherUserUid;
  final String otherUserName;

  const IndividualChatScreenWithProvider({
    super.key,
    required this.chatThreadId,
    required this.otherUserUid,
    required this.otherUserName,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:ChangeNotifierProvider(
      create:
          (_) => MessageListProvider(
            chatThreadId: chatThreadId,
            otherUserUid: otherUserUid,
          ),
      child: _IndividualChatScreenView(
        otherUserName: otherUserName,
        otherUserUid: otherUserUid,
      ),
    ));
  }
}

class _IndividualChatScreenView extends StatefulWidget {
  final String otherUserName;
  final String otherUserUid;
  const _IndividualChatScreenView({
    required this.otherUserName,
    required this.otherUserUid,
  });

  @override
  State<_IndividualChatScreenView> createState() =>
      _IndividualChatScreenViewState();
}

class _IndividualChatScreenViewState extends State<_IndividualChatScreenView> {
  final ImagePicker _picker = ImagePicker();
  late MessageListProvider _messageListProvider;
  UserProfileForChat? _otherUserProfile;

  @override
  void initState() {
    super.initState();
    _messageListProvider = Provider.of<MessageListProvider>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadOtherUserProfile();
        _messageListProvider.clearMessages();
        _messageListProvider.loadInitialMessages().then((_) {
          if (mounted) {
            // Start listening for new messages first
            _messageListProvider.listenToFirebaseMessages();
            // Then, mark all current messages as read
            _messageListProvider.markMessagesAsRead();
          }
        });
      }
    });
  }

    
  Future<void> _loadOtherUserProfile() async {
    final profile = await IsarService().getUserProfile(widget.otherUserUid);
    if (mounted) {
      setState(() {
        _otherUserProfile = profile;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null && mounted) {
        _messageListProvider.sendMessage(imageFile: pickedFile);
      }
    } catch (e) {
      print("Image picker error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessageListProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: [
            if (_otherUserProfile?.profileImageUrl != null &&
                _otherUserProfile!.profileImageUrl!.isNotEmpty)
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  _otherUserProfile!.profileImageUrl!,
                ),
              ),
            const SizedBox(width: 8),
            Text(
              widget.otherUserName,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          if (provider.isLoading && provider.displayItems.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (!provider.isLoading && provider.displayItems.isEmpty)
            const Expanded(
              child: Center(child: Text('No messages yet. Say Hi!')),
            )
          else
            Expanded(
              child: MessageListView(
                otherUserName: widget.otherUserName,
                otherUserProfile: _otherUserProfile,
              ),
            ),

          ReplyPreviewWidget(otherUserName: widget.otherUserName),
          MessageInputWidget(
            editingMessage: provider.editingMessage,
            isSending: provider.isSending,
            onSendMessage: provider.sendMessage,
            onSaveEditedMessage: provider.saveEditedMessage,
            onCancelEditing: provider.cancelEditing,
            onPickImage: _pickImage,
          ),
        ],
      ),
    );
  }
}
