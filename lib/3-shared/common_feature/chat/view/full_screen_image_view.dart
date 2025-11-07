import 'dart:io';
import 'package:flutter/foundation.dart'; // <-- ADDED
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:http/http.dart' as http;

class FullScreenImageView extends StatelessWidget {
  final String imageUrl; // This will be remoteUrl OR blob: url
  final String? localPath; // This will be file path (mobile-only) or null

  const FullScreenImageView({
    Key? key,
    required this.imageUrl,
    this.localPath,
  }) : super(key: key);

  Future<void> _saveImage(BuildContext context) async {
    // 1. ADD WEB CHECK
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving images is not supported on web.')),
      );
      return;
    }

    try {
      String? pathToSave;

      // 2. Mobile-only logic
      if (localPath != null && File(localPath!).existsSync()) {
        // ローカル画像がある場合
        pathToSave = localPath;
      } else {
        // ネットワーク画像を一時保存
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final file = await File(
            '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.png',
          ).create();
          await file.writeAsBytes(response.bodyBytes);
          pathToSave = file.path;
        }
      }

      if (pathToSave != null) {
        final result = await GallerySaver.saveImage(pathToSave);
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('画像を保存しました')),
          );
        } else {
          throw Exception('保存失敗');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Platform-aware image widget logic
    Widget imageWidget;
    if (kIsWeb) {
      // On web, localPath is always null. imageUrl has the blob or remote url.
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      // On mobile
      if (localPath != null && File(localPath!).existsSync()) {
        // Use local file if it exists (optimistic send)
        imageWidget = Image.file(File(localPath!));
      } else {
        // Use remote url
        imageWidget = CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 4. Hide save button on web
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _saveImage(context),
            ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: imageUrl, // Tag is always the main URL
          child: InteractiveViewer( // 5. Added for zooming
            panEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            child: imageWidget, // Use the determined widget
          ),
        ),
      ),
    );
  }
}