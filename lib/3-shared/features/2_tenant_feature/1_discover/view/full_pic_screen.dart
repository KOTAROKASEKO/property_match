// lib/2_tenant_feature/4_chat/view/full_screen_image_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String? localPath;

  const FullScreenImageView(
      {super.key, required this.imageUrl, this.localPath});

  Future<void> _downloadImage(BuildContext context) async {
    try {
      final Permission permission =
          Platform.isIOS ? Permission.photos : Permission.storage;

      PermissionStatus status = await permission.request();

      if (status.isGranted) {
        // ** FIX: Use the local path if it exists, otherwise use the image URL **
        final path = (localPath != null && File(localPath!).existsSync())
            ? localPath!
            : imageUrl;
        final success = await GallerySaver.saveImage(path);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(success == true
                    ? 'Image saved to gallery'
                    : 'Failed to save image.')),
          );
        }
      } else if (status.isPermanentlyDenied) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                  'This app needs storage access to save images. Please grant the permission in app settings.'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: const Text('Open Settings'),
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Storage permission is required to save images.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _downloadImage(context),
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            child: (localPath != null && File(localPath!).existsSync())
                ? Image.file(File(localPath!))
                : Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}