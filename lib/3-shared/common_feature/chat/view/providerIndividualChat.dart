// lib/common_feature/chat/view/providerIndividualChat.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../features/1_agent_feature/chat_template/model/property_template.dart';
import '../../../features/1_agent_feature/chat_template/view/property_template_carousel_widget.dart';
import '../../../features/1_agent_feature/chat_template/viewmodel/agent_template_viewmodel.dart';
import 'message_input_widget.dart';
import 'message_list_widget.dart';
import 'reply_widget.dart';
import '../viewmodel/messageList.dart';
import '../viewmodel/messageTemplate_viewmodel.dart';
import '../../../features/2_tenant_feature/1_discover/view/agent_profile_screen.dart';
import '../../../features/authentication/userdata.dart';

class IndividualChatScreenWithProvider extends StatelessWidget {
  final String chatThreadId;
  final String otherUserUid;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final PropertyTemplate? initialPropertyTemplate;

  const IndividualChatScreenWithProvider({
    super.key,
    required this.chatThreadId,
    required this.otherUserUid,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    this.initialPropertyTemplate,
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
            create: (_) =>
                MessagetemplateViewmodel(userRole: userData.role)
                  ..loadTemplates(),
          ),
        ],
        child: _IndividualChatScreenView(
          otherUserName: otherUserName,
          otherUserUid: otherUserUid,
          otherUserPhotoUrl: otherUserPhotoUrl,
          initialPropertyTemplate: initialPropertyTemplate,
        ),
      ),
    );
  }
}

class _IndividualChatScreenView extends StatefulWidget {
  final String otherUserName;
  final String otherUserUid;
  final String? otherUserPhotoUrl;
  final PropertyTemplate? initialPropertyTemplate;

  const _IndividualChatScreenView({
    required this.otherUserName,
    required this.otherUserUid,
    this.otherUserPhotoUrl,
    this.initialPropertyTemplate,
  });

  @override
  State<_IndividualChatScreenView> createState() =>
      _IndividualChatScreenViewState();
}

class _IndividualChatScreenViewState extends State<_IndividualChatScreenView> {
  final ImagePicker _picker = ImagePicker();
  late MessageListProvider _messageListProvider;
  PropertyTemplate? _templateToPreview; // ★ プレビュー用のStateを追加

  @override
  void initState() {
    super.initState();
    // ★ プレビュー用のテンプレートをStateにセット
    _templateToPreview = widget.initialPropertyTemplate;

    _messageListProvider = Provider.of<MessageListProvider>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _messageListProvider.clearMessages();
        _messageListProvider.loadInitialMessages().then((_) {
          if (mounted) {
            // ★ 自動送信ロジックは削除
            _messageListProvider.listenToFirebaseMessages();
            _messageListProvider.markMessagesAsRead();
          }
        });
      }
    });
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
        title: GestureDetector(
          onTap: () {
            if (userData.role == Roles.tenant) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      AgentProfileScreen(agentId: widget.otherUserUid),
                ),
              );
            }
          },
          child: Row(
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
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            if (provider.isLoading && provider.displayItems.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (!provider.isLoading &&
                provider.displayItems.isEmpty &&
                _templateToPreview == null)
              Expanded(
                child: userData.role == Roles.agent
                    ? PropertyTemplateCarouselWidget(
                        onTemplateSelected: (template) {
                          setState(() {
                            _templateToPreview = template;
                          });
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
              previewTemplate: _templateToPreview, // ★ プレビュー情報を渡す
              onCancelPreview: () {
                // ★ プレビューキャンセル時の処理
                setState(() {
                  _templateToPreview = null;
                });
              },
              onSendMessage:
                  ({
                    File? audioFile,
                    String? text,
                    XFile? imageFile,
                    PropertyTemplate? propertyTemplate,
                  }) {
                    // ★ シグネチャ変更
                    _messageListProvider.sendMessage(
                      audioFile: audioFile,
                      text: text,
                      imageFile: imageFile,
                      propertyTemplate: propertyTemplate,
                    );
                    // ★ テンプレートを送信したらプレビューをクリア
                    if (propertyTemplate != null) {
                      setState(() {
                        _templateToPreview = null;
                      });
                    }
                  },
              onSaveEditedMessage: provider.saveEditedMessage,
              onCancelEditing: provider.cancelEditing,
              onPickImage: _pickImage,
            ),
          ],
        ),
      ),
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
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        template,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.send),
                      onTap: () {
                        context.read<MessageListProvider>().sendMessage(
                          text: template,
                        );
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
