// lib/2_tenant_feature/4_chat/view/providerIndividualChat.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/common_feature/chat/view/chat_templates/text_template_carousel_widget.dart';
import 'package:re_conver/features/1_agent_feature/chat_template/view/property_template_carousel_widget.dart';
import 'package:re_conver/features/1_agent_feature/chat_template/viewmodel/agent_template_viewmodel.dart';
import 'package:re_conver/common_feature/chat/view/message_input_widget.dart';
import 'package:re_conver/common_feature/chat/view/message_list_widget.dart';
import 'package:re_conver/common_feature/chat/view/reply_widget.dart';
import 'package:re_conver/common_feature/chat/viewmodel/messageList.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:re_conver/common_feature/chat/viewmodel/messageTemplate_viewmodel.dart';
import 'package:re_conver/features/authentication/userdata.dart';
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
        // ★★★ 画面を開いたときに一度だけ許可を求める ★★★
        _checkAndRequestNotificationPermission();

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

  // ★★★ 通知許可を求めるダイアログのロジック ★★★
  Future<void> _checkAndRequestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    // 'notAsked' またはまだ何も保存されていない場合のみダイアログを表示
    if (prefs.getString('notification_permission_status') == null || prefs.getString('notification_permission_status') == 'notAsked') {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Notifications?'),
          content:
              const Text('Get notified about new messages and important updates.'),
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
        await prefs.setString(
            'notification_permission_status', status.isGranted ? 'granted' : 'denied');
      } else {
        // 「今はしない」を選択した場合も、'dismissed'として保存し、再表示しない
        await prefs.setString('notification_permission_status', 'dismissed');
      }
    }
  }

  
    Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null && mounted) {
        // ★★★ 直接sendMessageを呼び出すように変更 ★★★
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
                        _messageListProvider.sendMessage(text: messageText, propertyTemplate: template);
                      },
                    )
                  : const _TenantTextTemplatesView(),
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
              _messageListProvider.sendMessage(
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
              Expanded(
            child: Center(
              child: TextTemplateCarouselWidget(
                onTemplateSelected: (template) {
                  context.read<MessageListProvider>().sendMessage(text: template);
                },
              ),
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

class _TenantTextTemplatesView extends StatelessWidget {
  const _TenantTextTemplatesView();

  @override
  Widget build(BuildContext context) {
    return Consumer<MessagetemplateViewmodel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.templates.isEmpty) {
          return const Center(child: Text("No message templates found."));
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Start the conversation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.templates.length,
                itemBuilder: (context, index) {
                  final template = viewModel.templates[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      title: Text(template, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.send),
                      onTap: () {
                        context.read<MessageListProvider>().sendMessage(text: template);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}