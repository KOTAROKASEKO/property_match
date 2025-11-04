import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AudioMessagePlayer extends StatefulWidget {
  final MessageModel message;
  const AudioMessagePlayer({super.key, required this.message});

  @override
  State<AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero; // FIX: Reset position to the beginning
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = widget.message.isOutgoing;
    final color = isMe ? Colors.white : Colors.black87;

    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle : Icons.play_circle,
            color: color,
            size: 32,
          ),
          onPressed: () async {
            try {
              if (_isPlaying) {
                await _audioPlayer.pause();
              } else {
                // Check if we are paused mid-way
                if (_position > Duration.zero &&
                    _position.inMilliseconds < _duration.inMilliseconds) {
                  await _audioPlayer.resume();
                } else {
                  // We are at the start (0) or end (fully played)
                  // We must set the source and play.
                  Source? source;
                  if (widget.message.localPath != null) {
                    if (kIsWeb) {
                      source = UrlSource(widget.message.localPath!);
                    } else if (File(widget.message.localPath!).existsSync()) {
                      source = DeviceFileSource(widget.message.localPath!);
                    }
                  }

                  if (source == null && widget.message.remoteUrl != null) {
                    source = UrlSource(widget.message.remoteUrl!);
                  }

                  if (source != null) {
                    // This method sets the source AND starts playing
                    // It will also trigger onDurationChanged
                    await _audioPlayer.play(source);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Audio not available.')),
                      );
                    }
                  }
                }
              }
            } catch (e) {
              print("Error playing audio: $e");
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error playing audio: $e')),
                );
              }
            }
          },
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
            ),
            child: Slider(
              min: 0,
              max: (_duration.inSeconds.toDouble() > 0)
                  ? _duration.inSeconds.toDouble()
                  : 1.0,
              value: _position.inSeconds.toDouble().clamp(
                0.0,
                _duration.inSeconds.toDouble(),
              ),
              onChanged: (value) {
                setState(() {
                  _position = Duration(seconds: value.toInt());
                });
              },
              onChangeEnd: (value) async {
                final newPosition = Duration(seconds: value.toInt());
                await _audioPlayer.seek(newPosition);
              },
              activeColor: color,
              inactiveColor: color.withOpacity(0.3),
            ),
          ),
        ),
        Text(
          _formatDuration(_duration - _position),
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
