// lib/2_tenant_feature/4_chat/view/providerIndividualChat.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/1_agent_feature/chat_template/view/property_template_carousel_widget.dart';
import 'package:re_conver/1_agent_feature/chat_template/viewmodel/agent_template_viewmodel.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/message_input_widget.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/message_list_widget.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/reply_widget.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/template_carousel_vwidget.dart';
import 'package:re_conver/2_tenant_feature/4_chat/viewmodel/messageList.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:re_conver/2_tenant_feature/4_chat/viewmodel/messageTemplate_viewmodel.dart';
import 'package:re_conver/authentication/userdata.dart' show userData, Roles;
import 'package:shared_preferences/shared_preferences.dart';


class IndividualChatScreenWithProvider extends StatelessWidget {
  final String chatThreadId;
  final String otherUserUid;
  final String otherUserName;
  final String? otherUserPhotoUrl; // Added photo url

  const IndividualChatScreenWithProvider({
    super.key,
    required this.chatThreadId,
    required this.otherUserUid,
    required this.otherUserName,
    this.otherUserPhotoUrl, // Added photo url
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => MessageListProvider(
              chatThreadId: chatThreadId,
              otherUserUid: otherUserUid,
            ),
          ),
          ChangeNotifierProvider(create: (_) => AgentTemplateViewModel()),
          ChangeNotifierProvider(
            // ViewModel生成時に現在のユーザーの役割を渡す
            create: (_) => MessagetemplateViewmodel(userRole: userData.role)..loadTemplates(),
          ),
        ],
        child: _IndividualChatScreenView(
          otherUserName: otherUserName,
          otherUserUid: otherUserUid,
          otherUserPhotoUrl: otherUserPhotoUrl, // Pass photo url
        ),
      ),
    );
  }
}

class _IndividualChatScreenView extends StatefulWidget {
  final String otherUserName;
  final String otherUserUid;
  final String? otherUserPhotoUrl; // Added photo url

  const _IndividualChatScreenView({
    required this.otherUserName,
    required this.otherUserUid,
    this.otherUserPhotoUrl, // Added photo url
  });

  @override
  State<_IndividualChatScreenView> createState() =>
      _IndividualChatScreenViewState();
}

class _IndividualChatScreenViewState extends State<_IndividualChatScreenView> {
  final ImagePicker _picker = ImagePicker();
  late MessageListProvider _messageListProvider;

  @override
  void initState() {
    super.initState();
    _messageListProvider = Provider.of<MessageListProvider>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _messageListProvider.clearMessages();
        _messageListProvider.loadInitialMessages().then((_) {
          if (mounted) {
            _messageListProvider.listenToFirebaseMessages();
            _messageListProvider.markMessagesAsRead();
          }
        });
      }
    });
  }

  Future<void> _checkAndRequestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionStatus = prefs.getString('notification_permission_status');

    if (permissionStatus == null || permissionStatus == 'notAsked') {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Notifications?'),
          content: const Text(
              'Get notified about new messages and important updates.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not Now'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enable'),
            ),
          ],
        ),
      );

      if (result == true) {
        final status = await Permission.notification.request();
        if (status.isGranted) {
          await prefs.setString('notification_permission_status', 'granted');
        } else {
          await prefs.setString('notification_permission_status', 'denied');
        }
      } else {
        await prefs.setString('notification_permission_status', 'notAsked');
      }
    }
  }

  Future<void> _sendMessageWithPermissionCheck(
      {String? text, XFile? imageFile, File? audioFile}) async {
    await _checkAndRequestNotificationPermission();
    _messageListProvider.sendMessage(
        text: text, imageFile: imageFile, audioFile: audioFile);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null && mounted) {
        _sendMessageWithPermissionCheck(imageFile: pickedFile);
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
            if (widget.otherUserPhotoUrl != null &&
                widget.otherUserPhotoUrl!.isNotEmpty)
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  widget.otherUserPhotoUrl!,
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
            Expanded(
              child: userData.role == Roles.agent
                  ? PropertyTemplateCarouselWidget(
                      onTemplateSelected: (template) {
                        final messageText = '''
【Property Information】
Name: ${template.name}
Rent: RM ${template.rent.toStringAsFixed(0)}
Location: ${template.location}
Description:
${template.description}
Images:
${template.photoUrls.join('\n')}
                    ''';
                        _messageListProvider.sendMessage(text: messageText);
                      },
                    )
                  : const _ChatTemplatesCarousel(),
            )
          else
            Expanded(
              child: MessageListView(
                otherUserName: widget.otherUserName,
                otherUserPhotoUrl: widget.otherUserPhotoUrl,
              ),
            ),
          ReplyPreviewWidget(otherUserName: widget.otherUserName),
          MessageInputWidget(
            editingMessage: provider.editingMessage,
            isSending: provider.isSending,
            onSendMessage: (
                {File? audioFile, String? text, XFile? imageFile}) {
              _sendMessageWithPermissionCheck(
                  audioFile: audioFile, text: text, imageFile: imageFile);
            },
            onSaveEditedMessage: provider.saveEditedMessage,
            onCancelEditing: provider.cancelEditing,
            onPickImage: _pickImage,
          ),
        ],
      ),
    );
  }
}

class _ChatTemplatesCarousel extends StatelessWidget {
  const _ChatTemplatesCarousel();


  @override
  Widget build(BuildContext context) {
    return Consumer<MessagetemplateViewmodel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.templates.isEmpty) {
          return const Center(
            child: Text("No message templates found."),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 20),
              const Expanded(
            child: Center(
              child: TemplateCarouselWidget(isFullScreen: true),
            ),
          ),
              const SizedBox(height: 16),

            ],
          ),
        );
      },
    );
  }
}