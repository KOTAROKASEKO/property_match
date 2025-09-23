import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:http/http.dart' as http;

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String? localPath;

  const FullScreenImageView({
    Key? key,
    required this.imageUrl,
    this.localPath,
  }) : super(key: key);

  Future<void> _saveImage(BuildContext context) async {
    try {
      String? pathToSave;

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _saveImage(context),
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: (localPath != null && File(localPath!).existsSync())
              ? Image.file(File(localPath!))
              : CachedNetworkImage(imageUrl: imageUrl),
        ),
      ),
    );
  }
}
