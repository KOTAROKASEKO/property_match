// lib/common_feature/chat/view/message_input_widget.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/common_feature/chat/view/chat_templates/text_template_carousel_widget.dart';
import 'package:re_conver/features/1_agent_feature/chat_template/model/property_template.dart';
import 'package:re_conver/features/1_agent_feature/chat_template/view/property_template_carousel_widget.dart';
import 'package:re_conver/features/1_agent_feature/chat_template/viewmodel/agent_template_viewmodel.dart';
import 'package:re_conver/common_feature/chat/model/message_model.dart';
import 'package:re_conver/common_feature/chat/viewmodel/messageList.dart';
import 'package:re_conver/common_feature/chat/viewmodel/messageTemplate_viewmodel.dart';
import 'package:re_conver/features/authentication/userdata.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageInputWidget extends StatefulWidget {
  final Function({File? audioFile, String? text, XFile? imageFile, PropertyTemplate? propertyTemplate}) onSendMessage; // ★ シグネチャ変更
  final Function(String editedText) onSaveEditedMessage;
  final VoidCallback onCancelEditing;
  final VoidCallback onPickImage;
  final MessageModel? editingMessage;
  final bool isSending;
  final PropertyTemplate? previewTemplate; // ★ 追加
  final VoidCallback? onCancelPreview; // ★ 追加

  const MessageInputWidget({
    super.key,
    required this.onSendMessage,
    required this.onSaveEditedMessage,
    required this.onCancelEditing,
    required this.onPickImage,
    this.editingMessage,
    this.isSending = false,
    this.previewTemplate, // ★ 追加
    this.onCancelPreview, // ★ 追加
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  late TextEditingController _messageController;
  final FocusNode _textFieldFocusNode = FocusNode();
  late ValueNotifier<bool> _canPerformActionNotifier;
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  late MessageListProvider _messageListProvider;

  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;


  bool _isCancelled = false;
  static const double _cancelThreshold = 100.0;


  @override
  void initState() {
    super.initState();
    _messageListProvider = Provider.of<MessageListProvider>(
      context,
      listen: false,
    );
    _messageController = TextEditingController();
    _canPerformActionNotifier = ValueNotifier<bool>(
      _calculateCanPerformAction(),
    );
    _messageController.addListener(_onTextChanged);
    _updateTextForEditing(isInitial: true);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _updateTimer(Timer timer) {
    if (_isRecording) {
      setState(() {
        _recordingDuration += const Duration(milliseconds: 100);
      });
    } else {
      timer.cancel();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _handleMicPermission();
    if (!hasPermission) return;

    HapticFeedback.lightImpact();

    final path = '${(await getTemporaryDirectory()).path}/voice_message.m4a';
    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _recordingDuration = Duration.zero;
      _isCancelled = false;
    });
    _recordingTimer =
        Timer.periodic(const Duration(milliseconds: 100), _updateTimer);
  }

  Future<void> _stopRecording({bool cancelled = false}) async {
    if (!_isRecording) return;
    try {
      final path = await _audioRecorder.stop();
      if (path != null && !cancelled) {
        widget.onSendMessage(audioFile: File(path));
      } else if (path != null && cancelled) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print("Recording error: $e");
    } finally {
      _recordingTimer?.cancel();
      if(mounted) {
        setState(() {
          _isRecording = false;
          _isCancelled = false;
        });
      }
    }
  }


  Future<bool> _handleMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  void didUpdateWidget(MessageInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingMessage != oldWidget.editingMessage) {
      _updateTextForEditing();
    }
    if (widget.isSending != oldWidget.isSending) {
      _onTextChanged();
    }
    // ★ プレビューテンプレートの変更を検知
    if (widget.previewTemplate != oldWidget.previewTemplate) {
      _onTextChanged();
    }
  }

  void _onTextChanged() {
    _canPerformActionNotifier.value = _calculateCanPerformAction();
  }

  bool _calculateCanPerformAction() {
    if (widget.isSending || _isRecording) return false;
    // ★ テンプレートがあるか、テキストが空でない場合にアクション可能
    return widget.previewTemplate != null || _messageController.text.trim().isNotEmpty;
  }

  void _updateTextForEditing({bool isInitial = false}) {
    if (widget.editingMessage != null) {
      _messageController.text = widget.editingMessage!.messageText ?? '';
      if (!isInitial) {
        FocusScope.of(context).requestFocus(_textFieldFocusNode);
      }
    }
    _onTextChanged();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _textFieldFocusNode.dispose();
    _canPerformActionNotifier.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _handleSendOrSave() {
    if (!_canPerformActionNotifier.value) return;

    // ★ テンプレートがあればテンプレートを送信
    if (widget.previewTemplate != null) {
      widget.onSendMessage(propertyTemplate: widget.previewTemplate!);
      return; // テキストは送信しない
    }
    
    final text = _messageController.text.trim();
    if (widget.editingMessage != null) {
      widget.onSaveEditedMessage(text);
    } else {
      widget.onSendMessage(text: text);
    }
    _messageController.clear();
  }

  void _showTenantTextTemplatesBottomSheet(BuildContext context) {
    final templateViewModel = context.read<MessagetemplateViewmodel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: templateViewModel,
          child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.3,
              maxChildSize: 0.6,
              expand: false,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: TextTemplateCarouselWidget(
                    onTemplateSelected: (template) {
                      _messageController.text = template;
                      _messageController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _messageController.text.length));
                      _onTextChanged();
                      Navigator.of(ctx).pop();
                    },
                  ),
                );
              }),
        );
      },
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined,
                      color: Colors.deepPurple),
                  title: const Text('Photo Library'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    widget.onPickImage();
                  },
                ),

                if (userData.role == Roles.agent)
                  ListTile(
                    leading: const Icon(Icons.note_alt_outlined,
                        color: Colors.deepPurple),
                    title: const Text('Templates'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showAgentTemplateSelectionSheet(context);
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.note_alt_outlined,
                        color: Colors.deepPurple),
                    title: const Text('Message Templates'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showTenantTextTemplatesBottomSheet(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showPropertyTemplatesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: context.read<AgentTemplateViewModel>(),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.8,
            expand: false,
            builder: (_, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: PropertyTemplateCarouselWidget(
                  onTemplateSelected: (template) {
                    _messageListProvider.sendMessage(propertyTemplate: template);
                    Navigator.of(ctx).pop();
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAgentTemplateSelectionSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return SafeArea(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.apartment_outlined,
                        color: Colors.deepPurple),
                    title: const Text('Property Template'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      showPropertyTemplatesBottomSheet(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.note_alt_outlined,
                        color: Colors.deepPurple),
                    title: const Text('Message Template'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showTenantTextTemplatesBottomSheet(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).cardColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: _isRecording
                ? Row(
                    key: const ValueKey('recording_timer'),
                    children: [
                      Icon(Icons.mic, color: Colors.red.shade400),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(_recordingDuration),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                      ),
                    ],
                  )
                : IconButton(
                    key: const ValueKey('add_button'),
                    icon: const Icon(Icons.add_circle_outline, color: Colors.deepPurple),
                    onPressed: widget.isSending ? null : () => _showOptionsBottomSheet(context),
                  ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.0, 0.3),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offsetAnimation, child: child),
                );
              },
              child: _isRecording
                  ? _buildSlideToCancel()
                  : (widget.previewTemplate != null ? _buildTemplatePreview() : _buildTextInput()),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _canPerformActionNotifier,
            builder: (context, canPerformAction, child) {
              if (canPerformAction && !_isRecording) {
                return IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _handleSendOrSave,
                );
              } else {
                return GestureDetector(
                   onLongPressStart: (_) => _startRecording(),
                  onLongPressMoveUpdate: (details) {
                    if (!_isRecording) return;
                    final newSlidePosition = details.localPosition.dx;
                    setState(() {
                      if (newSlidePosition < -_cancelThreshold && !_isCancelled) {
                        HapticFeedback.mediumImpact();
                        _isCancelled = true;
                      } else if (newSlidePosition >= -_cancelThreshold && _isCancelled) {
                        _isCancelled = false;
                      }
                    });
                  },
                  onLongPressEnd: (_) => _stopRecording(cancelled: _isCancelled),
                  onLongPressCancel: () => _stopRecording(cancelled: true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: _isRecording ? 80 : 48,
                    height: _isRecording ? 80 : 48,
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? (_isCancelled ? Colors.red.shade300 : Colors.green.shade400)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mic,
                      color: _isRecording ? Colors.white : Theme.of(context).iconTheme.color,
                      size: _isRecording ? 40 : 28,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Padding(
      key: const ValueKey('text_input'),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        cursorColor: Colors.deepPurple,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        minLines: 1,
        maxLines: 5,
        controller: _messageController,
        focusNode: _textFieldFocusNode,
        decoration: InputDecoration(
          hintText: 'Type a message...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }
  
  Widget _buildSlideToCancel() {
    return Container(
      key: const ValueKey('slide_to_cancel'),
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back_ios, color: Colors.grey, size: 14),
          SizedBox(width: 8),
          Text("Slide to cancel", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ★ 新しいプレビューウィジェット
  Widget _buildTemplatePreview() {
    final template = widget.previewTemplate!;
    return Container(
      key: const ValueKey('template_preview'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.apartment, size: 24, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Property to Inquire", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  template.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: widget.onCancelPreview,
          )
        ],
      ),
    );
  }
}