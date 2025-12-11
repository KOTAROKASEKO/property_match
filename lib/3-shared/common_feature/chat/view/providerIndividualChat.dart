import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/common_feature/repository_provider.dart';
import 'package:re_conver/3-shared/features/1_agent_feature/2_tenant_list/view/tenant_detail_screen.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/3_profile/models/profile_model.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../../../features/1_agent_feature/chat_template/view/property_template_carousel_widget.dart';
import '../../../features/1_agent_feature/chat_template/viewmodel/agent_template_viewmodel.dart';
import 'message_input_widget.dart';
import 'message_list_widget.dart';
import 'reply_widget.dart';
import '../viewmodel/messageList.dart';
import '../viewmodel/messageTemplate_viewmodel.dart';
import '../../../features/2_tenant_feature/1_discover/view/agent_profile_screen.dart';

// 1. STATEFULWIDGET に変換
class IndividualChatScreenWithProvider extends StatefulWidget {
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
  State<IndividualChatScreenWithProvider> createState() =>
      _IndividualChatScreenWithProviderState();
}

class _IndividualChatScreenWithProviderState
    extends State<IndividualChatScreenWithProvider> {
  // 2. PROVIDER を STATE として管理
  late MessageListProvider _messageListProvider;
  late MessagetemplateViewmodel _messagetemplateViewmodel;
  late AgentTemplateViewModel _agentTemplateViewModel;

  @override
  void initState() {
    super.initState();
    // 3. INITSTATE で PROVIDER を作成
    _messageListProvider = MessageListProvider(
      chatThreadId: widget.chatThreadId,
      otherUserUid: widget.otherUserUid,
      chatRepository: getChatRepository(),
    );

    _messagetemplateViewmodel =
        MessagetemplateViewmodel(userRole: userData.role)..loadTemplates();
    
    _agentTemplateViewModel = AgentTemplateViewModel();
  }

  @override
  void didUpdateWidget(IndividualChatScreenWithProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 4. ID の変更を検知し、PROVIDER を再作成
    if (widget.chatThreadId != oldWidget.chatThreadId) {
      // 4a. 古い PROVIDER を dispose
      _messageListProvider.dispose();
      _messagetemplateViewmodel.dispose();

      // 4b. 新しい widget.chatThreadId で新しい PROVIDER を作成
      _messageListProvider = MessageListProvider(
        chatThreadId: widget.chatThreadId,
        otherUserUid: widget.otherUserUid,
        chatRepository: getChatRepository(),
      );

      _messagetemplateViewmodel =
          MessagetemplateViewmodel(userRole: userData.role)..loadTemplates();
    }
  }

  @override
  void dispose() {
    // 5. すべての PROVIDER を dispose
    _messageListProvider.dispose();
    _messagetemplateViewmodel.dispose();
    _agentTemplateViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiProvider(
        providers: [
          // 6. .VALUE コンストラクタを使用
          ChangeNotifierProvider.value(value: _messageListProvider),
          ChangeNotifierProvider.value(value: _messagetemplateViewmodel),
          ChangeNotifierProvider.value(value: _agentTemplateViewModel),
        ],
        child: _IndividualChatScreenView(
          // VIEW の KEY は引き続き必要
          key: ValueKey(widget.chatThreadId),
          otherUserName: widget.otherUserName,
          otherUserUid: widget.otherUserUid,
          otherUserPhotoUrl: widget.otherUserPhotoUrl,
          initialPropertyTemplate: widget.initialPropertyTemplate,
        ),
      ),
    );
  }
}

// ... _IndividualChatScreenView ...
class _IndividualChatScreenView extends StatefulWidget {
  final String otherUserName;
  final String otherUserUid;
  final String? otherUserPhotoUrl;
  final PropertyTemplate? initialPropertyTemplate;

  const _IndividualChatScreenView({
    super.key,
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
  PropertyTemplate? _templateToPreview;

  @override
  void initState() {
    super.initState();
    _templateToPreview = widget.initialPropertyTemplate;

    _messageListProvider = Provider.of<MessageListProvider>(
      context,
      listen: false,
    );
    
    // 親の StatefulWidget が正しいインスタンスを保証するため、このロジックは安全です
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
    final bool isUserBlocked = provider.isBlocked;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            // ★ テナントがエージェントを見る場合 (既存ロジック)
            if (userData.role == Roles.tenant) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      AgentProfileScreen(agentId: widget.otherUserUid),
                ),
              );
            } 
            // ★ エージェントがテナントを見る場合 (追加ロジック)
            else if (userData.role == Roles.agent) {
              try {
                // プロフィールデータを取得
                final doc = await FirebaseFirestore.instance
                    .collection('users_prof')
                    .doc(widget.otherUserUid)
                    .get();

                if (doc.exists && context.mounted) {
                  final tenantProfile = UserProfile.fromFirestore(doc);
                  
                  // ★★★ 修正: 画面遷移ではなくボトムシートを表示 ★★★
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // コンテンツの高さに応じて調整、フルスクリーンに近い表示が可能
                    backgroundColor: Colors.transparent, // 背景を透明にして角丸などを綺麗に見せる
                    builder: (context) {
                      return DraggableScrollableSheet(
                        initialChildSize: 0.85, // 画面の85%の高さで開始
                        maxChildSize: 0.95,     // 最大95%
                        minChildSize: 0.5,      // 最小50%
                        expand: false,          // コンテンツサイズに合わせる設定 (Center配置のためfalse推奨)
                        builder: (context, scrollController) {
                          // ★ レスポンシブ対応: Center と ConstrainedBox で最大幅を制限
                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600), // PC等で広がりすぎないように制限
                              child: Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                // TenantDetailSheetContent自体がスクロール可能なので、ここではそのまま配置
                                // (scrollControllerを渡していないため、ドラッグ操作との連動は限定的ですが、コンテンツのスクロールは可能です)
                                child: TenantDetailSheetContent(tenant: tenantProfile),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile not found.')),
                    );
                  }
                }
              } catch (e) {
                print("Error fetching tenant profile: $e");
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not load profile.')),
                  );
                }
              }
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
              Expanded(
                child: Text(
                  widget.otherUserName,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis, // Good practice
                  maxLines: 1,                      // Good practice
                ),
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
                            _templateToPreview = template as PropertyTemplate?;
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
            if (isUserBlocked)
              _buildBlockedBanner() // ★ ブロック中バナー
            else
            MessageInputWidget(
              editingMessage: provider.editingMessage,
              isSending: provider.isSending,
              previewTemplate: _templateToPreview,
              onCancelPreview: () {
                setState(() {
                  _templateToPreview = null;
                });
              },
              onSendMessage:
                  ({
                    XFile? audioFile, // <-- Web対応のため XFile
                    String? text,
                    XFile? imageFile,
                    PropertyTemplate? propertyTemplate,
                  }) {
                    _messageListProvider.sendMessage(
                      audioFile: audioFile, // <-- XFile を渡す
                      text: text,
                      imageFile: imageFile,
                      propertyTemplate: propertyTemplate,
                    );
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
  
  Widget _buildBlockedBanner() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: Text(
          "The user is not available.",
          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
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