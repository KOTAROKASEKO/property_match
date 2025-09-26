// lib/2_tenant_feature/4_chat/view/message_input_widget.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/message_model.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/template_carousel_vwidget.dart';
import 'package:re_conver/2_tenant_feature/4_chat/viewmodel/messageTemplate_viewmodel.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageInputWidget extends StatefulWidget {
  final Function({File? audioFile, String? text, XFile? imageFile})
      onSendMessage;
  final Function(String editedText) onSaveEditedMessage;
  final VoidCallback onCancelEditing;
  final VoidCallback onPickImage;
  final MessageModel? editingMessage;
  final bool isSending;

  const MessageInputWidget({
    super.key,
    required this.onSendMessage,
    required this.onSaveEditedMessage,
    required this.onCancelEditing,
    required this.onPickImage,
    this.editingMessage,
    this.isSending = false,
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

  // New state variables for recording UI
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  double? _longPressStartX;

  @override
  void initState() {
    super.initState();
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
    });
    _recordingTimer =
        Timer.periodic(const Duration(milliseconds: 100), _updateTimer);
  }

  Future<void> _stopRecordingAndSend() async {
    if (!_isRecording) return;
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        widget.onSendMessage(audioFile: File(path));
      }
    } catch (e) {
      print("Recording error: $e");
    } finally {
      _recordingTimer?.cancel();
      setState(() => _isRecording = false);
    }
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording) return;
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print("Error cancelling recording: $e");
    } finally {
      _recordingTimer?.cancel();
      setState(() => _isRecording = false);
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
  }

  void _onTextChanged() {
    _canPerformActionNotifier.value = _calculateCanPerformAction();
  }

  bool _calculateCanPerformAction() {
    if (widget.isSending || _isRecording) return false;
    return _messageController.text.trim().isNotEmpty;
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
    final text = _messageController.text.trim();
    if (widget.editingMessage != null) {
      widget.onSaveEditedMessage(text);
    } else {
      widget.onSendMessage(text: text);
    }
    _messageController.clear();
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
                  leading: const Icon(Icons.camera_alt_outlined,
                      color: Colors.deepPurple),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Camera not implemented yet.')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined,
                      color: Colors.deepPurple),
                  title: const Text('Photo Library'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    widget.onPickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.note_alt_outlined,
                      color: Colors.deepPurple),
                  title: const Text('Templates'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showTemplatesBottomSheet(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTemplatesBottomSheet(BuildContext context) {
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
                  child: TemplateCarouselWidget(
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).cardColor,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: _isRecording ? _buildRecordingUi() : _buildTextInputUi(),
      ),
    );
  }

  Widget _buildTextInputUi() {
    return Row(
      key: const ValueKey('text_input_ui'),
      children: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.deepPurple),
          onPressed:
              widget.isSending ? null : () => _showOptionsBottomSheet(context),
        ),
        Expanded(
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _canPerformActionNotifier,
          builder: (context, canPerformAction, child) {
            if (canPerformAction) {
              return IconButton(
                icon: const Icon(Icons.send, color: Colors.deepPurple),
                onPressed: _handleSendOrSave,
              );
            } else {
              return GestureDetector(
                onLongPressStart: (details) {
                  _longPressStartX = details.globalPosition.dx;
                  _startRecording();
                },
                onLongPressEnd: (details) {
                  if (!_isRecording) return;
                  final endX = details.globalPosition.dx;
                  final screenWidth = MediaQuery.of(context).size.width;
                  if (_longPressStartX != null &&
                      (_longPressStartX! - endX) > (screenWidth / 4)) {
                    _cancelRecording();
                  } else {
                    _stopRecordingAndSend();
                  }
                  _longPressStartX = null;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.mic_none_outlined,
                    color: Theme.of(context).iconTheme.color,
                    size: 28,
                  ),
                ),
              );
            }
          },
        ),
        if (widget.editingMessage != null)
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: widget.onCancelEditing,
          ),
      ],
    );
  }

  Widget _buildRecordingUi() {
    return Row(
      key: const ValueKey('recording_ui'),
      children: [
        const Icon(Icons.mic, color: Colors.red),
        const SizedBox(width: 16),
        Text(
          _formatDuration(_recordingDuration),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
        const Text("Slide to cancel", style: TextStyle(color: Colors.grey)),
        const SizedBox(width: 16),
      ],
    );
  }
}